---
layout: post
title: "Android UI struggles: making a button with centered text and icon"
date: 2013-03-23T14:04:00+01:00
categories:
 - Rant
 - Android
 - UI
---

Every time I work on the UI of Android app I get the feeling that there is either something terribly wrong with the Android UI framework or with my understanding of how it works. I can reason about how the app works on the higher level, but I cannot apply the same methodology to Android UI, except for the simplest designs. I have read a lot of Android source code, I have written few dozens of sample-like apps, but I still cannot just think of the views structure, type it in and be done - for complicated layouts with some optional elements (i.e. which are sometimes visible and sometimes gone) I need at least few attempts and, I confess, sometimes I'm desperate enough to do the "let's change this and see what happens" coding. Extremely frustrating.

I'm going to describe my struggles with Android UI on this blog, so if I'm doing something terribly wrong, hopefully someone will enlighten me by posting a comment; and in case something is terribly wrong with Android UI framework, I might be able to help other programmers in distress.

Today I have a simple task for you: create a button with some text and icon to the left of the text. The contents (both icon and text) should be centered inside the button.

{% img center /images/challenge.png %}

That's simple right? Here's the XML layout which comes to mind first:

``` xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical" >

    <Button
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:drawableLeft="@android:drawable/ic_delete"
        android:gravity="center"
        android:text="Button Challenge" />

</LinearLayout>
```

Unfortunately, no cookie for you:

{% img center /images/try1.png %}

Someone decided that compound drawables should be always draw next to the `View`'s padding, so we have to try something else. For example `TextView` centered inside the `FrameLayout`.

``` xml
<FrameLayout
    style="?android:attr/buttonStyle"
    android:layout_width="match_parent"
    android:layout_height="wrap_content" >

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:drawableLeft="@android:drawable/ic_delete"
        android:gravity="center"
        android:text="Button Challenge" />
</FrameLayout>
```

{% img center /images/try2.png %}

Almost there, but the text has a wrong size and color. There is something called `textAppearanceButton`, but apparently it's not what the `Button`s use:

{% img center /images/try3.png %}

OK, so let's use the buttonStyle again, this time on `TextView`:

{% img center /images/try4.png %}

Now we need to get rid of the extra background, reset minimum height and width and make it not focusable and not clickable (otherwise tapping the caption won't have any effect):

``` xml
<FrameLayout
    style="?android:attr/buttonStyle"
    android:layout_width="match_parent"
    android:layout_height="wrap_content" >

    <TextView
        style="?android:attr/buttonStyle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:background="@null"
        android:clickable="false"
        android:drawableLeft="@android:drawable/ic_delete"
        android:focusable="false"
        android:gravity="center"
        android:minHeight="0dp"
        android:minWidth="0dp"
        android:text="Button Challenge" />
</FrameLayout>
```

Lo and behold, it works!

{% img center /images/challenge.png %}

We'd really like to use is something like `textAppearance="?android:attr/buttonStyle.textAppearance"`, but there is no such syntax. How about extracting all the attributes from `TextView` into some `buttonCaption` style with `?android:attr/buttonStyle` parent? No can do either: you can only inherit your style from the concrete `@style`, not from the styleable attribute.

But what we can do is to use `Button` and create a style with no parent: Android will use the default button style and apply our captionOnly style:

``` xml
<style name="captionOnly">
    <item name="android:background">@null</item>
    <item name="android:clickable">false</item>
    <item name="android:focusable">false</item>
    <item name="android:minHeight">0dp</item>
    <item name="android:minWidth">0dp</item>
</style>

<FrameLayout
    style="?android:attr/buttonStyle"
    android:layout_width="match_parent"
    android:layout_height="wrap_content" >

    <Button
        style="@style/captionOnly"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:drawableLeft="@android:drawable/ic_delete"
        android:gravity="center"
        android:text="Button Challenge" />
</FrameLayout>
```
