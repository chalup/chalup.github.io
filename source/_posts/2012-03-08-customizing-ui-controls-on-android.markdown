---
layout: post
title: "Customizing UI controls on Android"
date: 2012-03-08T15:09:00+01:00
categories:
 - Android
---

By customizing I mean "Oh, and can we have buttons with pink background and neon green text" requests you get from your customers. It turns out that such simple requests are in fact not simple. Take a look at the following screenshots taken on HTC Desire phone:

{% img center /images/customizingUIcontrols.png %}

The "Nexus" button uses custom background selector copied from Android sources, so it looks exactly like a buttons on Nexus phones. The "HTC" button is using default background selector for HTC phones. As you can see there are few differences: highlight, corner rounding and slightly different padding. Other vendors also customize default look of UI controls: Motorola uses red highlight, and Samsung tablets use light blue highlight and there are probably some minor differences in padding and rounding as well.

Let's get back to the original problem, i.e. using pink background and neon green text. Obviously we cannot change just the text color, because it would be unreadable on HTC devices. Changing the background is also tricky, because you cannot reuse highlight graphics built into the platform resources: the different padding and corner rounding force you to use custom graphics for every state. Using layer list drawable to add some decoration is also out of the question, because of the differences in padding - most likely your decoration would be off by few pixels on some devices.

But now you have one completely custom UI control, which stands apart of built in controls. So for me it's rather "all or nothing" approach - either you customize all your UI controls (which might be very time consuming) or you use default controls.

I found one exception to this unfortunate situation: it's possible to create a ListView items with custom "normal" background and default highlight. Just use the following selector for list item background:

``` xml
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_selected="true" android:drawable="@android:color/transparent" />
    <item android:state_focused="true" android:drawable="@android:color/transparent" />
    <item android:state_pressed="true" android:drawable="@android:color/transparent" />
    <item android:drawable="@drawable/list_item" />
</selector>
```
