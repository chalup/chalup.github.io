---
layout: post
comments: true
title: "Guava and minSdkVersion"
date: 2013-06-26T23:03:00+02:00
categories:
 - Guava
 - Gotcha
 - Android
---

A while ago [I wrote about pre-dexing](/blog/2013/02/20/guava-on-android) feature introduced at the end of 2012, which facilitates using large Java libraries like Guava for developing Android apps. Few months later, I'm still discovering stuff in Guava that makes my life easier (BTW: I still owe you a blog post with a list of Guava goodies). But this week, for a change, I've managed to make my life harder with Guava.

I wanted to include the javadocs and source jars for Guava, and when I opened maven central I saw the new version and decided to upgrade from 13.0.1 to 14.0.1. Everything went smoothly except for the minor Proguard hiccup: you have to include [the jar with the `@Inject` annotation](https://code.google.com/p/atinject/). At least it went smoothly on the first few phones I've tested our app on, but on some ancient crap with Android 2.2 the app crashed with [`NoClassDefFoundError`](http://developer.android.com/reference/java/lang/NoClassDefFoundError.html).

The usual suspect in this case is, of course, Proguard. I've also suspected the issue similar to [the libphonenumber crash I wrote about in March](/blog/2013/03/23/libphonenumber-crash-on-android-32). When both leads turned out to be a dead end, I decided to run the debug build and to my surprise it crashed as well. And there was a logcat message which pinpointed the issue: the `ImmutableSet` in Guava 14.0.1 depends somehow on [`NavigableSet`](http://developer.android.com/reference/java/util/NavigableSet.html) interface, which is available from API level 9. Sad as I was, I downgraded the Guava back to 13.0.1 and everything started to work again.

So what have I learned today?

* Upgrading the libraries for the sake of upgrading is bad (m'kay).
* Before you start wrestling with Proguard, test the debug build.
* Android 2.2 doesn't support all Java 1.6 classes.

The scary thing is, the similar thing might happen again if some other class in Guava depends on APIs unavailable on older versions of Android. Sounds like a good idea for a weekend hack project: some way to mark or check the minSdkVersion needed to use a given class or method.
