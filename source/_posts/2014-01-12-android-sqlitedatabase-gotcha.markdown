---
layout: post
title: "Android SQLiteDatabase gotcha"
date: 2014-01-12T22:15:00+01:00
categories:
 - SQLite
 - Gotcha
 - Android
---

In my [previous post](/blog/2014/01/03/offline-mode-in-android-apps-part-2) I mentioned a nasty `SQLiteDatabase` gotcha and recommended using the `MigrationHelper` utility I wrote. If you have checked this [class's sources](https://github.com/futuresimple/android-schema-utils/blob/master/src/main/java/com/getbase/android/schema/MigrationsHelper.java), you might have noticed a weird code. Before getting the list of columns the table is renamed to the temporary name and then renamed back:

``` java
final String tempTable = "tmp_" + tempTableIndex++;
db.execSQL("ALTER TABLE " + migration.tableName + " RENAME TO " + tempTable);
ImmutableSet<String> oldColumns = getColumns(db, tempTable);

db.execSQL(migration.createTableStatement);
final String tempNewTable = "tmp_" + tempTableIndex++;
db.execSQL("ALTER TABLE " + migration.tableName + " RENAME TO " + tempNewTable);
ImmutableSet<String> newColumns = getColumns(db, tempNewTable);

db.execSQL("ALTER TABLE " + tempNewTable + " RENAME TO " + migration.tableName);

private static ImmutableSet<String> getColumns(SQLiteDatabase db, String table) {
  Cursor cursor = db.query(table, null, null, null, null, null, null, "0");
  if (cursor != null) {
    try {
      return ImmutableSet.copyOf(cursor.getColumnNames());
    } finally {
      cursor.close();
    }
  }
  return ImmutableSet.of();
}
```

Initially the `MigrationHelper`'s code looked like this:

``` java
static final String TEMP_TABLE = "tmp";
db.execSQL("ALTER TABLE " + migration.tableName + " RENAME TO " + TEMP_TABLE);
ImmutableSet<String> oldColumns = getColumns(db, TEMP_TABLE);

db.execSQL(migration.createTableStatement);
ImmutableSet<String> newColumns = getColumns(db, migration.tableName);
```

It worked for a single migration, but didn't work for multiple migrations - the helper method for getting the column set always returned the columns of first table. Since the query was always the same, I suspected the results are cached somewhere. To verify this hypothesis I added to the temporary table name an index incremented with every migration. It worked, but then I realized I need to do the same for getting the columns of the new schema - otherwise the helper wouldn't work if the same table were migrated twice. This way the weird code was born.

But the same thing could happen outside of `MigrationHelper` operations, for example if you need to iterate through rows of the same table in two different migrations:

``` java
@Override
public void onUpgrade(final SQLiteDatabase db, int oldVersion, int newVersion) {
  if (oldVersion <= 1500) {
    Cursor c = db.query("some_table", /* null, null, null... */);
    // use Cursor c
  }

  // other migrations, including ones that change the some_table table's columns

  if (oldVersion <= 2900) {
    Cursor c = db.query("some_table", /* null, null, null... */);
    // try to use Cursor c and crash terribly
  }
}
```

So I checked the AOSP code for the suspected cache to see how the entries can be evicted or if the cache can be disabled. There are no methods for this, so you can't do it with straightforward call, but maybe you can exploit the implementation details?

On ICS the cache is implemented as [`LruCache`](http://developer.android.com/reference/android/util/LruCache.html), so theoretically you could evict old entries by filling the cache with new ones, but there is one hiccup - you don't know the cache size, so you'd always have to go with [`MAX_SQL_CACHE_SIZE`](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#MAX_SQL_CACHE_SIZE).

Before ICS you couldn't do even that - the implementation of this "cache" is just a fixed size buffer for `SQLiteStatements`. Once that buffer is full, no more statements are cached. This also has one more consequence - your app might work much slower on Android 2.x after upgrade from old version than after fresh install, because the db cache will be filled with queries used in migrations.

Fortunately the keys of this cache are raw SQL strings, so we can disable cache for migration queries by adding `WHERE n==n` clause with n incremented for every query (note that you musn't pass n as a bound parameter - the whole point of adding this selection is to make the queries different and force `SQLiteDatabase` to compile another statement).

The question you should ask yourself is why do I have to know and care about all this. Isn't SQLite smart enough to see that I'm trying to access the database using prepared statement compiled against old schema? It turns out the SQLite detects this issues and raises `SQLITE_SCHEMA` error (commented with "The database schema changed"), but Android's `SQLiteDatabase` wrapper drops this error and happily uses the old, invalid statements. Bad Android.
