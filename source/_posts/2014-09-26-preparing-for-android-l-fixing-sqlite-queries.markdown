---
layout: post
title: "Preparing for Android L - fixing SQLite queries"
date: 2014-09-26 19:13:21 +0200
comments: true
categories: 
 - Android
 - SQLite
 - gotcha
---

Today during the routine check of Android crash reports, I saw that one of the custom SQLite queries fails with `ambiguous column: id` message. There were two interesting aspects of this issue: nobody touched this part of code for a while; and there were only handful of crashes from a single device, and when you have a botched query it should crash left, right and center.

Fortunately a while back we decided to log the sqlite version available on a given device, so I had the crucial piece of information that let me find the root cause in no time. This particular device used custom ROM with Sqlite 3.8.x installed, which caught my eye, because the standard version used by Android 4.x is 3.7.11. 

Here's the [short, self contained, correct example](http://sscce.org/):

```sql
CREATE TABLE x (id INTEGER);
CREATE TABLE y (id INTEGER, x_id INTEGER);
SELECT * FROM x LEFT JOIN y ON x.id=y.x_id GROUP BY id
```

SQLite 3.7.11 assumes the user wants to group the rows by `x.id`, 3.8 fails with `ambiguous column: id` error, which is more sensible thing to do. The fix is trivial:

```sql
SELECT * FROM x LEFT JOIN y ON x.id=y.x_id GROUP BY x.id
```

What's really important about this gotcha is that sqlite 3.8 will be the default version used by Android L, rumored to be released on November 1st. You might say that you don't have any custom queries in your app, but you'd have to consider every dependency performing any data persistence you use. The best course of action is to test your application thoroughly on device with L preview image or emulator.
