---
layout: post
title: "SQLite type affinity strikes back"
date: 2013-06-06T22:22:00+02:00
categories:
 - SQLite
 - Gotcha
 - Android
 - SQL
---

About a year ago I have wrote about a certain [SQLite gotcha on Android](/blog/2012/06/22/sqlite-unions-gotcha). **tl;dr**: in some cases when you create a view with unions, SQLite cannot determine a type of the column, and since Android binds all selection arguments as strings, SQLite ends up comparing X with "X", concludes those are not the same thing and returns fewer rows than you'd expect.

Recently the same problem reared it's ugly head. It turns out that it's very easy to create in a view a column with undefined type. It might happen in case of joins, using aggregation functions, subqueries, etc. pretty much anything more fancy than simple select. Therefore I recommend checking the columns type using the `pragma table_info(table)` command for **every** view:

```
sqlite> .head on
sqlite> .mode column
sqlite> pragma table_info (v);

cid         name        type        notnull     dflt_value  pk
----------  ----------  ----------  ----------  ----------  ----------
0           test                    0                       0
```

If the type of a column is undefined and you need to use this column in your selection arguments, you should add the UNION with an empty row with well defined column types:

```
sqlite> CREATE TABLE types (i INTEGER, t TEXT);
sqlite> CREATE VIEW vfix AS SELECT i AS test FROM types WHERE 1=0 UNION SELECT * FROM v;
sqlite> pragma table_info (vfix);

cid         name        type        notnull     dflt_value  pk
----------  ----------  ----------  ----------  ----------  ----------
0           test        INTEGER     0                       0
```
