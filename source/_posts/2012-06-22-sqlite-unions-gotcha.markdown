---
layout: post
comments: true
title: "SQLite unions gotcha"
date: 2012-06-22T23:03:00+02:00
categories:
 - SQLite
 - Gotcha
 - Android
 - SQL
---

Recently I've been tracking the problem with SQLite database used in the Android application I'm working on. The starting point of the whole story is that I've noticed that the cursor created with the `SQLiteDatabase.query()` method returned smaller data set than the same query executed through sqlite3 command line interface. The query in question looked like this:

``` sql
SELECT * FROM some_view WHERE (column_a=1 OR column_b=1);
```

Inside the Android app I was getting rows for the second part of OR clause (i.e. `column_b=1`), but no rows for the first part.

Quick search through Android sources yielded the clue - I wasn't executing exactly the same query on the command line. Selection arguments are always bound as a strings, so the question marks in query string should be surrounded with quotes. So the Android app was executing the following query:

``` sql
SELECT * FROM some_view WHERE (column_a="1" OR column_b="1");
```

So now we have another puzzle: why `column_b=1` and `column_b="1"` give the same results, but the behavior is different for `column_a`? Let's try to reproduce the problem:

```
sqlite> .mode column
sqlite> .headers on
sqlite> CREATE TABLE t (x INTEGER);
sqlite> INSERT INTO t VALUES(1);
sqlite> SELECT COUNT(*) FROM t WHERE x=1;
1
sqlite> SELECT COUNT(*) FROM t WHERE x="1";
1
```

So far so good, no surprises. Let's create a view similar to the one which causes problems.

```
sqlite> CREATE VIEW v AS SELECT NULL AS a, x AS b FROM t UNION SELECT x, NULL FROM t;
sqlite> SELECT * FROM v;
a           b
----------  ----------
            1
1
```

Now let's take a look at counts:

```
sqlite> SELECT COUNT(*) FROM v WHERE b=1;
COUNT(*)
----------
1
sqlite> SELECT COUNT(*) FROM v WHERE b="1";
COUNT(*)
----------
1
sqlite> SELECT COUNT(*) FROM v WHERE a=1;
COUNT(*)
----------
1
sqlite> SELECT COUNT(*) FROM v WHERE a="1";
COUNT(*)
----------
0
```

Yay, we reproduced our bug. But why is this happening?

```
sqlite> PRAGMA TABLE_INFO(v);
cid         name        type        notnull     dflt_value  pk
----------  ----------  ----------  ----------  ----------  ----------
0           a                       0                       0
1           b           integer     0                       0
```

It seems that the lack of explicitly defined type of the first column prevents type conversion (please note that this is only my assumption based on the observations above; unfortunately the sqlite documentation doesn't cover such cases in detail). How can we work around this issue?

```
sqlite> CREATE VIEW vfix AS SELECT x AS a, x AS b FROM t WHERE 1=0 UNION SELECT * FROM v;
sqlite> PRAGMA TABLE_INFO(vfix);
cid         name        type        notnull     dflt_value  pk
----------  ----------  ----------  ----------  ----------  ----------
0           a           integer     0                       0
1           b           integer     0                       0
```

As you can see the column types are correctly copied from the underlying table. Let's check the counts:

```
sqlite> SELECT COUNT(*) FROM vfix WHERE b=1;
COUNT(*)
----------
1
sqlite> SELECT COUNT(*) FROM vfix WHERE b="1";
COUNT(*)
----------
1
sqlite> SELECT COUNT(*) FROM vfix WHERE a=1;
COUNT(*)
----------
1
sqlite> SELECT COUNT(*) FROM vfix WHERE a="1";
COUNT(*)
----------
1
```

Looks OK. Pretty? No, but it does the job and that's what matters at the end of the day.
