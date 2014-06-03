---
layout: post
comments: true
title: "Use minSdkVersion=10 for libraries"
date: 2014-02-25T21:42:00+01:00
categories:
 - Thneed
 - Guava
 - Android
 - minSdkVersion
 - MicroOrm
---

I've pushed new versions of [microorm](https://github.com/chalup/microorm) and [thneed](https://github.com/chalup/thneed) to Maven Central today. The most notable change for both libraries is dropping the support for Android 2.2 and earlier versions. The same change was applied to all Android libraries open sourced by [Base](https://github.com/orgs/futuresimple/). Why? [+Jeff Gilfelt](https://plus.google.com/104992412719307414985) summed it up nicely:

<blockquote class="twitter-tweet" lang="en"><p>Because it is 2014 <a href="https://t.co/UCMaZOB6Sl">https://t.co/UCMaZOB6Sl</a></p>&mdash; Jeff Gilfelt (@readyState) <a href="https://twitter.com/readyState/statuses/435419373852184576">February 17, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

This tweet is a good laugh (and an excellent example of what happens if you limit the discussion to 140 characters), but there are poor souls who might need an answer they can use as an objective argument. For them, here is my take on this one: you should drop support for Froyo because sizeable chunk of Java 1.6 APIs were missing from API level 8. I'm not talking about some dark corners of java packages, I'm talking about stuff like [`String.isEmpty()`](http://developer.android.com/reference/java/lang/String.html#isEmpty%28%29), [`Deque`](http://developer.android.com/reference/java/util/Deque.html), [`NavigableSet`](http://developer.android.com/reference/java/util/NavigableSet.html), [`IOException`](http://developer.android.com/reference/java/io/IOException.html)'s constructors with cause parameter, [and so on](http://developer.android.com/sdk/api_diff/9/changes/changes-summary.html).

Your own code can (and should) be checked with Lint, but these methods and classes can also be used by the 3rd party libraries and I'm not aware of any static analysis tool that can help you in this case. So if your app supports Froyo and uses a lot of external dependencies, you're probably sitting on the [NoClassDefFoundError bomb](/blog/2013/06/26/guava-and-minsdkversion). It might force you to use obsolete versions of libraries, the most notable example of which is Guava - on Froyo you have to use 13.0.1, a 18 months old version.

That's also the reason why the libraries authors should be the first ones to move on to Android 2.3 and later. If you use obsolete library in your application, you're hurting only yourself. If you use it as a library dependency, you're hurting every user of the library.

So move on and bump the minSdkVersion. After all, it's 2014.
