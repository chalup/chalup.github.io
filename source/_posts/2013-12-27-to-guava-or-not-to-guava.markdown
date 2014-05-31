---
layout: post
title: "To Guava or not to Guava?"
date: 2013-12-27T12:10:00+01:00
categories:
 - Guava
 - fragmentation
 - minSdkVersion
---

I faced this dilemma recently, when I was preparing first release of [Cerberus](https://github.com/chalup/cerberus) utility for Android. On one hand, in [Cerberus](https://github.com/chalup/cerberus) I used a tiny subset of Guava features which can be trivially rewritten in vanilla Java in 15 minutes, so maybe I should not force Guava down peoples throat?  On the other hand I'm a [huge](/blog/2013/09/21/guava-goodies) [fan](/blog/2013/10/04/more-guava-goodies-abstractiterator) of Guava and I think you should definitely use it in anything more complicated than "Hello, world!" tutorial, because it either reduces a boilerplate or replaces your handrolled utilities with better, faster and more thoroughly tested implementations.

The "this library bloats my apk" argument is moot, because you can easily set up the ProGuard configuration which only strips the unused code, without doing any expensive optimizations. It's a good idea, because the dex input will be smaller, which speeds up the build and the apk will be smaller, which reduces time required to upload and install the app on the device.

I found the problem though, which is a bit harder to solve. Modern versions of Guava use some [Java 1.6 APIs, which are available from API level 9](http://developer.android.com/reference/java/util/NavigableSet.html), so when you try to use it on Android 2.2 (API level 8), you'll get the `NoSuchMethodException` or some other unpleasant runtime error (side note: position #233 on my TODO list was a jar analyzer which finds this problem). [On Android 2.2 you're stuck with Guava 13.0.1.](/blog/2013/06/26/guava-and-minsdkversion)

This extends also to Guava as a library dependency. If one library supports Android 2.2 and older, it forces old version of Guava as dependency. And if another library depends on more recent version of Guava, you're basically screwed.

One conclusion you can draw from this blog post is that you shouldn't use Guava in your open source libraries to prevent dependency hell, but that's spilling the baby with the bathwater. The problem is not Guava or any other library, the problem are Java 1.6 methods missing from Android API level 8! [The statistics from Google](http://developer.android.com/about/dashboards/index.html) indicates that Froyo is used by 1.6%, in case of Base CRM user base it's only 0.2%. So more reasonable course of action is finally **bumping minSdkVersion to 10** ([or even 14](http://dannyroa.com/2013/10/17/why-its-time-to-support-only-android-4-0-and-above/)), both for your applications and all the libraries.
