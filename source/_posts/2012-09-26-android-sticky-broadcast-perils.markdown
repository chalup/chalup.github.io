---
layout: post
title: "Android sticky broadcast perils"
date: 2012-09-26T10:16:00+02:00
categories:
 - Android
---

I might have called this blog post "Android sticky broadcasts considered harmful", but ["Considered harmful" texts are considered harmful](http://meyerweb.com/eric/comment/chech.html), so I opted for a less linkbaity title.

I was working on a bug in a legacy code which used sticky broadcasts for publishing the sync service state (BTW: if you thought "Hello, [`ContentResolver.isSyncActive()`](http://developer.android.com/reference/android/content/ContentResolver.html#isSyncActive%28android.accounts.Account, java.lang.String%29)?" you should subscribe to my blog feed - I'm planning to write about the problems with sync state methods in ContentResolver). The bug manifested as a minor UI issue - sometimes the UI indicated that sync is in progress, even in situations when the sync could not be in progress, for example because the network connection was down. The QA team found an easy reproduction steps for it: start sync and reinstall the app before the sync finishes.

I found much more troubling reproduction steps: start sync, uninstall app while sync is in progress and then install it again. The difference between those steps and the ones found by QA is the fact that I'm performing uninstall, which means that all information about my app should be wiped from the system.

I dug deeper and found out two scary facts:

* Sticky broadcasts are not connected in any way to app package, which means they are not removed on uninstallation. They **are** removed on phone restart, but that's not a scenario you should rely upon.
* Any application with [BROADCAST_STICKY permission](http://developer.android.com/reference/android/Manifest.permission.html#BROADCAST_STICKY) may alter your sticky broadcasts.

As long as you don't use sync status for anything more complicated than showing a spinner in Action Bar, you might get away with only minor UI issues, but if you want to use it for business logic, you're entering the world of pain.

The sticky broadcasts might be garbage left over by the old version of your app or some other app if you've chosen the action string poorly (protip: if you **really** have to use sticky broadcasts, include your app's package name in action string). Even if you ignore the latter case (and the very unlikely scenario of other app maliciously tinkering with your app's intents), I consider the former case to be a deal breaker - each sticky broadcast is an additional state which has to be migrated between app versions and app installations which further increases cognitive load of programming, which is high enough already.

Let's summarize this blog post: remove `BROADCAST_STICKY` permission from your app's AndroidManifest.xml, test the app, fix all crashes from SecurityExceptions and never look back.
