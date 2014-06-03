---
layout: post
comments: true
title: "Guava on Android"
date: 2013-02-20T22:15:00+01:00
categories:
 - Proguard
 - Guava
 - Android
 - build system
---

In November 2012, the revision 21 of Android SDK Tools was released and one of the items in the [release notes](http://developer.android.com/tools/sdk/tools-notes.html) made me a very happy panda:

{% blockquote %}
Improved the build time by pre-dexing libraries (both JAR files and library projects).
{% endblockquote %}

This change solved the most problematic issue with [Guava](http://code.google.com/p/guava-libraries/) and other large libraries - build time. Before this change Android tools executed dex for your code and every referenced library every time you wanted to launch the application, which in case of Guava took ages and required increasing heap space for Java VM, because the Eclipse closed with "Unable to execute dex: Java heap space" error.

IntelliJ users could work around this issue by enabling Proguard for debug builds, which could reduce the size of dex input by removing unused code. Eclipse users might try generalizing the [Treeshaker plugin](http://code.google.com/p/treeshaker/), which does pretty much the same inside a custom compilation step added before dexing. But there was no straight way to use Guava and keep the build times on the sane level.

Now the first build still takes ages, and the Eclipse still crashes if you don't bump its heap space, but for all consecutive builds everything works blazing fast. Goodbye hand rolled stuff, welcome [immutable collections](http://code.google.com/p/guava-libraries/wiki/ImmutableCollectionsExplained), [fluent comparators](http://code.google.com/p/guava-libraries/wiki/OrderingExplained), [hashCode helper](http://code.google.com/p/guava-libraries/wiki/CommonObjectUtilitiesExplained#hashCode) and tons of [other goodness](http://code.google.com/p/guava-libraries/wiki/GuavaExplained). I keep finding in our code base whole chunks of code which can be replaced with one or two lines utilizing Guava features. I plan to post a summary of those changes.

Final note: if you are using Proguard, remember to add Guava specific entries [mentioned in the documentation](http://code.google.com/p/guava-libraries/wiki/UsingProGuardWithGuava).
