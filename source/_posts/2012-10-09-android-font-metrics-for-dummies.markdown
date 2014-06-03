---
layout: post
comments: true
title: "Android font metrics for dummies"
date: 2012-10-09T22:59:00+02:00
categories:
 - Rant
 - Android
 - UI
 - Layout
---

Recently I was working on a custom View with overridden [`onDraw()`](http://developer.android.com/reference/android/view/View.html#onDraw%28android.graphics.Canvas%29) method and at some point I needed to center some text vertically. Unfortunately [`Paint.setTextAlign()`](http://developer.android.com/reference/android/graphics/Paint.html#setTextAlign%28android.graphics.Paint.Align%29) supports only horizontal orientation, so I tried calculating the y-coordinate of the origin myself, but I couldn't get it exactly right. After two failed attempts I decided that I need a program which visualizes the available font metrics, because it seems that I do not understand the [`FontMetrics`](http://developer.android.com/reference/android/graphics/Paint.FontMetrics.html) documentation, or the aforementioned class and it's documentation sucks.

You can find the [source code on my GitHub](https://github.com/chalup/android-fontmetricstest), and here's the screenshot for other typographically challenged programmers:

{% img center /images/fontsfordummies.png %}

(BTW: the word "Żyłę" used there is not a complete gibberish, it's an accusative case of word "vein" in Polish; it's nice, because it's short, but it covers all cases of the metrics class).

Let's get back to vertical alignment. In general you should center text vertically either on [x-height](http://en.wikipedia.org/wiki/X-height) or on half the [cap height](http://en.wikipedia.org/wiki/Cap_height) above the [baseline](http://en.wikipedia.org/wiki/Baseline_%28typography%29) (at least that's the info I found). Neither metric is directly available in [`FontMetrics`](http://developer.android.com/reference/android/graphics/Paint.FontMetrics.html) class, but you can approximate the cap height as a `textSize - descent` or calculate x-height yourself using Rect height returned by [`Paint.getTextBounds`](http://developer.android.com/reference/android/graphics/Paint.html#getTextBounds%28java.lang.String, int, int, android.graphics.Rect%29) for string "x".
