---
layout: post
comments: true
title: "Android gets nested fragments"
date: 2012-11-13T21:31:00+01:00
categories:
 - Fragments
 - Android
 - UI
 - Layout
---

Most of the items in the [Android 4.2 APIs list](http://developer.android.com/about/versions/android-4.2.html) are kind of "meh" to me, but there is one item that's make me very happy: [nested fragments](http://developer.android.com/about/versions/android-4.2.html#NestedFragments). Fragments were supposed to be reusable UI components, but for some unfathomable reason the initial release of the fragments API didn't allow composing a fragment from other fragments. Even during the 2012 Google I/O one of the Google developers said that they have discussed this idea, but they're not sure if it's a good one, which is an absolute surprise to me, because I don't think anyone sane would consider making the [`ViewGroup`](http://developer.android.com/reference/android/view/ViewGroup.html) which isn't a subclass of a [`View`](http://developer.android.com/reference/android/view/View.html).

Fragment nesting was a topic I kept on my topic list for a day when I feel I need to bitch about something, but now I'm happy to remove it and write this ecstatic post. So now launch your SDK managers and download the r11 of support package! (or wait for half a year and hope it will be added to [Maven Central](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.google.android%22%20AND%20a%3A%22support-v4%22))
