---
layout: post
title: "Offline mode in Android apps, part 2 - SQLite's ALTER TABLE"
date: 2014-01-03T20:29:00+01:00
categories:
 - SQLite
 - offline mode
 - Android
 - db
---

In [first part of this series](/blog/2013/12/26/offline-mode-in-android-apps-part-1) I showed that to implement offline mode in your Android app you have to implement data migrations. If you're using SQLite database, it means you'll have to use (or rather work around) it's ALTER TABLE syntax:

[{% img center http://www.sqlite.org/images/syntax/alter-table-stmt.gif %}](http://www.sqlite.org/images/syntax/alter-table-stmt.gif)

So all you can do with it is adding the column or renaming the table, but in reality you probably need to alter a single column, remove column or change the table constraints. You can achieve this by doing the following operation:

1. Rename the table T with old schema to old_T.
1. Create the table T with new schema.
1. Use "INSERT INTO T (new_columns) SELECT old_columns FROM old_T" query to populate the table T with the data from the renamed table old_T.
1. Drop old_T.

Doing it manually is quite error prone though: for every migration you have to specify the new_columns and old_columns list. What's worse, in 95% of cases you just want to list the columns common for old and new schema. Fortunately we can automate such trivial migrations by executing `SELECT` with `LIMIT 0` (or `PRAGMA TABLE_INFO`) for both tables, getting the columns set using [`Cursor.getColumnNames()`](http://developer.android.com/reference/android/database/Cursor.html#getColumnNames%28%29), and calculating these columns sets intersection.

You can write a nice wrapper for this yourself, but a) I already did it, so you don't have to and b) there is a [very nasty gotcha](/blog/2014/01/12/android-sqlitedatabase-gotcha) which would probably cost you few hours of teeth grinding, so do yourself a favor and check [this repository](https://github.com/futuresimple/android-schema-utils) out, especially the [`MigrationsHelper`](https://github.com/futuresimple/android-schema-utils/blob/master/src/main/java/com/getbase/android/schema/MigrationsHelper.java) class. It automates the trivial migrations and allows you to define a mappings for situations when you rename the column or add a non-nullable column in new schema.

In the next two posts I'll [describe the gotcha I've mentioned](/blog/2014/01/12/android-sqlitedatabase-gotcha) in the previous paragraph and show some other non-obvious consequences of doing data migrations.
