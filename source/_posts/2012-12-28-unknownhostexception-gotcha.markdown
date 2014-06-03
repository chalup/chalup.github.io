---
layout: post
comments: true
title: "UnknownHostException gotcha"
date: 2012-12-28T11:28:00+01:00
categories:
 - Gotcha
 - Android
---

Several days ago I was preparing a simple app for the programming contest organized by [Future Simple](https://getbase.com/) during [KrakDroid](http://www.krakdroid.pl/) conference. It consisted of a public [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html), [`SyncAdapter`](http://developer.android.com/reference/android/content/AbstractThreadedSyncAdapter.html) and an [`Activity`](http://developer.android.com/reference/android/app/Activity.html). The contest participants had to write an app which retrieves the input data from [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html), solve a very simple algorithmic problem and save the output back in the [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html). This would trigger the sync and the [`SyncAdapter`](http://developer.android.com/reference/android/content/AbstractThreadedSyncAdapter.html) would upload the data to our backend. The [`Activity`](http://developer.android.com/reference/android/app/Activity.html) showed the contest rules and the list of submissions.

As you can see it's nothing fancy and I hacked everything together rather quickly, but when I tried to send the first submission I got the [`UnknownHostException`](http://developer.android.com/reference/java/net/UnknownHostException.html) from [`AbstractHttpClient.execute()`](http://developer.android.com/reference/org/apache/http/impl/client/AbstractHttpClient.html#execute%28org.apache.http.client.methods.HttpUriRequest%29). Had I [googled](https://www.google.pl/search?q=android+UnknownHostException) the issue first, I'd solve this issue in one minute. The problem is, my internet connection was flaky and the backend I tried to connect to was set up couple hours earlier, so the [`UnknownHostException`](http://developer.android.com/reference/java/net/UnknownHostException.html) seemed like a quite probable error.

If you haven't click the Google link above, here's the solution: this exception is a way in which Android tells you that your app is missing the [INTERNET](http://developer.android.com/reference/android/Manifest.permission.html#INTERNET) permission.
