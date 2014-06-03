---
layout: post
comments: true
title: "SQLite views gotcha"
date: 2013-12-03T00:13:00+01:00
categories:
 - SQLite
 - Gotcha
 - Android
 - SQL
---

**tl;dr:** don't left join on view, or you gonna have a bad time.

I have investigated a performance issue of the db in Android app today. The symptoms looked like a classic case of the missing index: the performance degraded with adding more data to certain tables. However, the quick check of sqlite_master table and looking at some `EXPLAIN QUERY PLAN` queries indicated that everything is properly indexed (which is not very surprising, given that we use [android-autoindexer](https://github.com/futuresimple/android-autoindexer)).

I started dumping the explain query plans for every query and it turned out that some queries perform multiple table scans instead of single scan of main table + indexed searches for joined tables. It means that the indices were in place, but they weren't used.

The common denominator of these queries was joining with a view. Here's the simplest schema which demonstrates the issue:

```
sqlite> create table x (id integer);
sqlite> create table y (id integer, x_id integer);

sqlite> explain query plan select * from x left join y on x.id = x_id;
selectid    order       from        detail
----------  ----------  ----------  ----------------------------------------------------------------
0           0           0           SCAN TABLE x (~1000000 rows)
0           1           1           SEARCH TABLE y USING AUTOMATIC COVERING INDEX (x_id=?) (~7 rows)

sqlite> create view yyy as select * from y;

sqlite> explain query plan select * from x left join yyy on x.id = x_id;
selectid    order       from        detail
----------  ----------  ----------  -------------------------------------------------------------------
1           0           0           SCAN TABLE y (~1000000 rows)
0           0           0           SCAN TABLE x (~1000000 rows)
0           1           1           SEARCH SUBQUERY 1 USING AUTOMATIC COVERING INDEX (x_id=?) (~7 rows)
```

Of course this behaviour is documented in the SQLite Query Planner overview (point 3 of the [Subquery flattening](http://www.sqlite.org/optoverview.html#flattening) paragraph), and I even remember reading this docs few times, but I guess something like this has to bite me in the ass before I memorize it.

Everything works fine if you copypaste the views selection in place of the joined view, which makes me a sad panda, because I wish SQLite could do this for me. On the other hand it's a very simple workaround for this issue, and, with a right library, the code might even be manageable.
