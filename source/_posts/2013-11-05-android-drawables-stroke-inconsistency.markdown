---
layout: post
title: "Android drawables stroke inconsistency"
date: 2013-11-05T00:34:00+01:00
categories:
 - Android
 - UI
 - drawables
---

I've run into a funny little problem when creating custom drawables recently - some of the lines were crisp and some were blurred:

{% img center /images/zoomed.png %}

After few debug iterations I was able to narrow down the difference to the shapes drawn using the [`Canvas.drawRoundRect`](http://developer.android.com/reference/android/graphics/Canvas.html#drawRoundRect%28android.graphics.RectF, float, float, android.graphics.Paint%29) and [`Canvas.drawPath`](http://developer.android.com/reference/android/graphics/Canvas.html#drawPath%28android.graphics.Path, android.graphics.Paint%29). The former looked much crispier. I've dug down to Skia classes and it turns out that they reach the same drawing function through slightly different code paths and I guess at some point some rounding is applied at one of them, but I haven't verified this.

The minimal example which demonstrates the issue are two solid [XML shape drawables](http://developer.android.com/guide/topics/resources/drawable-resource.html#Shape) (which are parsed into [`GradientDrawables`](http://developer.android.com/reference/android/graphics/drawable/GradientDrawable.html)), one with radius defined in radius attribute, the other one with four radii defined (can be the same).

Besides satisfying my idle curiosity and honing my AOSP code diving skills, I have learned something useful: do not mix paths and round rects on `Canvas` and use `Path.addRoundRect` with radii array when your path contains other curved shapes.
