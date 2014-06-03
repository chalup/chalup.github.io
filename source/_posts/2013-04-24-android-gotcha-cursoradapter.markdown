---
layout: post
comments: true
title: "Android gotcha: CursorAdapter constructors"
date: 2013-04-24T23:14:00+02:00
categories:
 - memory leak
 - Gotcha
 - Android
---

I just spend few hours analyzing and fixing a memory leak in Android application. With every orientation change the full `Context`, including the whole `Activity` was leaked. Long story short, the problem was caused by misuse of `CursorAdapter`: in subclass constructor we called [`CursorAdapter(context, null, false)`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html#CursorAdapter%28android.content.Context, android.database.Cursor, boolean%29) instead of [`CursorAdapter(context, null, 0)`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html#CursorAdapter%28android.content.Context, android.database.Cursor, int%29).

The difference is quite subtle. If you use the second constructor, you have to take care of handling content updates yourself. If you use the first constructor, the `CursorAdapter` will register an additional `ContentObserver` for you, but you need to manually reset the `Cursor`.

The funny thing is, this behavior is described in javadocs, but the documentation is spread between the [constructor](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html#CursorAdapter%28android.content.Context, android.database.Cursor, boolean%29) and [`FLAG_REGISTER_CONTENT_OBSERVER`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html#FLAG_REGISTER_CONTENT_OBSERVER) flag documentation. The second part contains most crucial information: you don't need to use this flag when you intend to use your adapter with `CursorLoader`.

If for some reason you want to use the adapter without `CursorLoader`, you should use the [`CursorAdapter(context, null, false)`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html#CursorAdapter%28android.content.Context, android.database.Cursor, boolean%29) constructor, and call [`swapCursor(null)`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html#swapCursor%28android.database.Cursor%29) when leaving the `Activity` or `Fragment`.
