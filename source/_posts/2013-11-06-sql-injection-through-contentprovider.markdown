---
layout: post
title: "SQL injection through ContentProvider projection"
date: 2013-11-06T23:45:00+01:00
categories:
 - SQL injection
 - SQLite
 - Android
 - security
 - db
---

The [SQL injection](http://en.wikipedia.org/wiki/SQL_injection) through query parameters is the common security issue of any system using SQL database. Android is no different than any other system, so if you're using SQLite database in your Android app, you should always sanitize the database inputs.

[{% img center http://imgs.xkcd.com/comics/exploits_of_a_mom.png Obligatory XKCD %}](http://imgs.xkcd.com/comics/exploits_of_a_mom.png)

If you are also using an exported [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html), you need to take care of one more vector of attack: the projection parameter of the queries. Just like [`SQLiteDatabase`](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html), the [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html) allows the users to specify which columns they want to retrieve. It makes sense, because it reduces the amount of data fetched, which might improve performance and reduce the RAM footprint of your app. Unlike the [`SQLiteDatabase`](http://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html), the [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html) might be exported, which means that the external applications can query the data from it requesting an arbitrary projection, which are then turned into raw SQL queries. For example:

``` sql
'Bobby Tables was here'; DROP TABLE Students; --
* FROM sqlite_master; --
* FROM non_public_table_I_found_out_about_using_previous_query; --
```

Basically it means that if you exposed a single uri without sanitizing the projection, you have exposed your entire db.

So how do you sanitize your projections? I've given it some thought and it seems that the only sensible thing to do is allowing only subsets of predefined set of columns.

You cannot allow any expression, because you'd allow any expressions, including SELECTs from other tables and allowing certain expressions is not a trivial task.

You shouldn't ignore the provided projection and return all columns, because one of the benefits of using projections is limiting the amount of data retrieved from database. Besides, [certain widely used Google application](https://play.google.com/store/apps/details?id=com.google.android.gm) ignores the existence of [`Cursor.getColumnIndex`](http://developer.android.com/reference/android/database/Cursor.html#getColumnIndex%28java.lang.String%29) method and assumes that the columns will be returned in the same order they were specified in projection. The other app won't work correctly, and the users will probably blame you.
