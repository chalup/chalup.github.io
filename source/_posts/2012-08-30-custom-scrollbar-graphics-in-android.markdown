---
layout: post
title: "Custom scrollbar graphics in Android"
date: 2012-08-30T16:04:00+02:00
categories:
 - Gotcha
 - fragmentation
 - Android
---

One of the UI elements you might want to customize in your app are scrollbars for ListViews, ScrollViews and other scrollable objects. It's a minor visual change, but it might give your app more consistent and polished look and feel, especially in case of the heavily branded UI.

Anyways, changing the default scrollbar style is dead simple - you just need to specify new drawables for the track and thumb in your style:

``` xml
<style name="badList">
    <item name="android:scrollbarThumbVertical">@drawable/scrollbar_handle</item>
    <item name="android:scrollbarTrackVertical">@drawable/scrollbar_track</item>
</style>
```

Of course, there is a small gotcha (why else would I bother to write this blog post?). Let's say that you don't need to customize horizontal scrollbar, so you prepare only vertical 9-patches:

{% img center /images/zoom_vertical.png %}

On Ice Cream Sandwich everything looks fine, but on Gingerbread the graphics are not exactly what you want:

{% img center /images/badstyle.png %}

Quick [Google search](https://www.google.pl/search?q=android+incorrect+custom+scrollbar+width) returned a [StackOverflow thread](http://stackoverflow.com/questions/3736768/android-scrollview-scrollbarsize) with a description and link to [Android bug tracker](http://code.google.com/p/android/issues/detail?id=14317), but no full workaround. If you're too lazy to click on those links, on Gingerbread and earlier releases the View asks ScrollbarDrawable for the height of horizontal scrollbar and uses it as a horizontal scrollbar height and vertical scrollbar width. Let's modify our scrollbar graphics a bit:

{% img center /images/zoomed_symmetric.png %}

And apply it as both horizontal and vertical scrollbar.

``` xml
<style name="goodList">
    <item name="android:scrollbarThumbVertical">@drawable/scrollbar_handle</item>
    <item name="android:scrollbarTrackVertical">@drawable/scrollbar_track</item>
    <item name="android:scrollbarThumbHorizontal">@drawable/scrollbar_handle</item>
    <item name="android:scrollbarTrackHorizontal">@drawable/scrollbar_track</item>
</style>
```

Lo and behold, it works!

{% img center /images/goodstyle.png %}

Note: in general case you probably want to create another graphics for horizontal scrollbar by rotating and flipping vertical scrollbar graphics. Our scrollbar graphics doesn't have any non-symmetric elements and I'm lazy, so I used the same 9-patch for both scrollbars.

The code of the sample application can be found [here](https://github.com/chalup/blog-scrollbargotcha).
