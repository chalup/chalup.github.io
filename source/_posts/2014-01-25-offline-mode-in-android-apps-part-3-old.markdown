---
layout: post
comments: true
title: "Offline mode in Android apps, part 3 - old db schemas"
date: 2014-01-25T11:43:00+01:00
categories:
 - SQLite
 - Gotcha
 - offline mode
 - Android
 - db
---

The [first post in this series](/blog/2013/12/26/offline-mode-in-android-apps-part-1) explained the first consequence on implementing the offline mode - performing the data migrations. In [second part](/blog/2014/01/03/offline-mode-in-android-apps-part-2) I showed a workaround for the rudimentary SQLite's ALTER TABLE syntax. If you have checked the link to [`MigrationHelper`](https://github.com/futuresimple/android-schema-utils/blob/master/src/main/java/com/getbase/android/schema/MigrationsHelper.java) class I mentioned, you migth have noticed that it's just a tiny part of a [larger library](https://github.com/futuresimple/android-schema-utils), which allows you to define database schemas. Note the plural "schemas": the whole point of this library is defining both current schema and the schemas for the older versions of your app. This post explains why do you have to do this.

Let's say in the first version you have the following data structure:

``` java
public static class User {
  public long id;
  public String firstName;
  public String lastName;
  public String email;
}
```

And the table definition for this table in your [`SQLiteOpenHelper`](http://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper.html) looks like this:

``` java
private static final String CREATE_TABLE_USERS = "CREATE TABLE " +
    TABLE_USERS +
    " ( " +
    ID + " INTEGER PRIMARY KEY AUTOINCREMENT " + ", " +
    FIRST_NAME + " TEXT " + ", " +
    LAST_NAME + " TEXT " + ", " +
    EMAIL + " TEXT " +
    " ) ";
```

In the next version you decide to keep only the first name in a single field, so you change your data structure accordingly and perform the data migration. In the snippet below I used the `MigrationHelper`, but you might have as well performed the migration by hand:

``` java
private static final String CREATE_TABLE_USERS = "CREATE TABLE " +
    TABLE_USERS +
    " ( " +
    ID + " INTEGER PRIMARY KEY AUTOINCREMENT " + ", " +
    NAME + " TEXT " + ", " +
    EMAIL + " TEXT " +
    " ) ";

@Override
public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
  MigrationsHelper helper = new MigrationsHelper();
  if (oldVersion < 2) {
    helper.performMigrations(db, 
        TableMigration.of(TABLE_USERS)
            .to(CREATE_TABLE_USERS)
            .withMapping(NAME, FIRST_NAME)
            .build()
    );
  }
}
```

Then you decide that the email field should be mandatory, so you change the schema and migrate the data again:

``` java
private static final String CREATE_TABLE_USERS = "CREATE TABLE " +
    TABLE_USERS +
    " ( " +
    ID + " INTEGER PRIMARY KEY AUTOINCREMENT " + ", " +
    NAME + " TEXT " + ", " +
    EMAIL + " TEXT NOT NULL" +
    " ) ";

@Override
public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
  MigrationsHelper helper = new MigrationsHelper();
  if (oldVersion < 2) {
    helper.performMigrations(db,
        TableMigration.of(TABLE_USERS)
            .to(CREATE_TABLE_USERS)
            .withMapping(NAME, FIRST_NAME)
            .build()
    );
  }
  if (oldVersion < 3) {
    db.execSQL("DELETE FROM " + TABLE_USERS + " WHERE " + EMAIL + " IS NULL");
    helper.performMigrations(db,
        TableMigration.of(TABLE_USERS)
            .to(CREATE_TABLE_USERS)
            .build()
    );
  }
}
```

The code looks fine, but you have just broken migrations from v1 to v3. If there is an user with a null email field, the app will crash in line 13 above. But why, shouldn't the email field in v2 schema be nullable? It should, but this migration uses the constant containing the latest schema definition with different column constraint.

The worst thing about this kind of bugs is that it might slip through your tests, because the crash happens only if you have a specific data before the application update.

You migth be tempted to define separate migrations from every old version to the latest one (in our case migrations from v1 to v3 and from v2 to v3) and always execute only single migration, but this workaround doesn't scale. For each new migration you'd have to check and potentially update every existing migration. When you publish the app twice a month, this quickly becomes a huge problem.

The other solution is to make every migration completely independent from the others, and execute them sequentially. This way, when you define a new migration, you don't have to worry about the previous ones. This means that when you upgrade from v1 to v3, you first upgrade from v1 to v2 and then from v2 to v2 and after the first step the database should be in the same state it were, when the v2 was the latest version. In other words, you have to keep an old database schemas.

As usual there are multiple ways to do this. You can copy the schema definition to another constant and append "ver#" suffix, but it means there will be a lot of duplicated code (although this code should never, ever change, so it's not as bad as the regular case of copypaste). The other way is to keep the initial database state and all the schema updates. The issue here is that you don't have a place in your code with current schema definition. The opposite solution is to keep the current schema and the list of downgrades. Sounds counterintuitive? Don't worry, that's because it ***is*** counterintuitive.

In [android-schema-utils](https://github.com/futuresimple/android-schema-utils) I've chosen the third approach, because in the long run it processes less data than the upgrades solution - in case of upgrade from vN-1 to vN it has to generate only 1 additional schema instead of N-1 schemas. I'm still not sure if the code wouldn't be clearer had I went with duplicated schema definitions approach, but the current approach, once you get used to it, works fine. The schema and migrations for our example would look like this:

``` java
private static final MigrationsHelper MIGRATIONS_HELPER = new MigrationsHelper();
private static final Schemas SCHEMAS = Schemas.Builder
    .currentSchema(3,
        new TableDefinition(TABLE_USERS,
            new AddColumn(ID, "INTEGER PRIMARY KEY AUTOINCREMENT"),
            new AddColumn(NAME, "TEXT"),
            new AddColumn(EMAIL, "TEXT NOT NULL")
        )
    )
    .upgradeTo(3,
        new SimpleMigration() {
          @Override
          public void apply(SQLiteDatabase db, Schema schema) {
            db.execSQL("DELETE FROM " + TABLE_USERS + " WHERE " + EMAIL + " IS NULL");
          }
        },
        auto()
    )
    .downgradeTo(2,
        new TableDowngrade(TABLE_USERS, new AddColumn(EMAIL, "TEXT"))
    )
    .upgradeTo(2,
        SimpleTableMigration.of(TABLE_USERS)
            .withMapping(NAME, FIRST_NAME)
            .using(MIGRATIONS_HELPER)
        )
    .downgradeTo(1,
        new TableDowngrade(TABLE_USERS,
            new AddColumn(FIRST_NAME, "TEXT"),
            new AddColumn(LAST_NAME, "TEXT"),
            new DropColumn(EMAIL)
        )
    )
    .build();
```

There are other benefits of keeping the old schemas in a more reasonable format than raw strings. Most of the schema migrations can be deducted from comparing subsequent schema versions, so you don't have to do it yourself. For example in migration from v2 to v3 I didn't have to specify that I want to migrate the Users table - the `auto()` migration automatically handles it. If the `auto()` is the only migration for a given upgrade, you can skip the whole `upgradeTo()` block. In our case that covered about 50% migrations, but YMMV.

If you go this way, your `onUpgrade` method, which usually is the most complex part of `SQLiteOpenHelper`, can be reduced to this:
``` java
@Override
public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
  SCHEMAS.upgrade(oldVersion, mContext, db);
}
```

This part concludes the "offline mode" series. Here's the short recap:

* If you don't want to compromise on UX, your application should work regardless whether the user is connected to internet or not.
* In this case the user may end up in a situation when the application is upgraded, but not all data is synced with the server yet. You ***do not*** want to lose your users' data. You'll have to migrate them.
* If you migrate your data, you should keep the migrations separate from one another, because otherwise maintaining them becomes a nightmare.
* The best way to do this that I know of, is keeping the old schemas and always performing all migrations sequentially. To make things simpler, I recommend the [android-schema-utils library](https://github.com/futuresimple/android-schema-utils).
