---
layout: post
comments: true
title: "DIP on BlackBerry"
date: 2012-03-02T21:35:00+01:00
categories:
 - Layout
 - BlackBerry
---

Android has this nice notion of [density-independent pixel](http://developer.android.com/guide/practices/screens_support.html#density-independence) - a measurement unit which ensures the widgets have the same physical size on the devices with different screen size and different resolution. Basically 1dp is 1px on a device with 160dpi and is scaled appropriately on devices with different dpi.

Why is it important? Because if you design your UI in px on high resolution device and then run it on low resolution device, you'll end up with gigantic buttons which take 50% of the screen. If you do the opposite, you'll end up with button, which are too small to click on high res device.

[{% img center http://developer.android.com/images/screens_support/density-test-bad.png %}](http://developer.android.com/images/screens_support/density-test-bad.png)

Unfortunately the BlackBerry doesn't support this concept out of the box. By default you specify the size and position of UI controls in regular pixels. The [BlackBerry documentation](http://docs.blackberry.com/en/developers/deliverables/29251/Developing_apps_for_different_screen_sizes_1579421_11.jsp) suggests using this nugget of a code:

``` java
boolean lowRes = Display.getWidth() <= 320;

if (lowRes)
{
    // The device has a low resolution screen size
}
else
{
    // The device has a high resolution screen size
}
```

But I think there is a better way.

The net.rim.device.api.ui.Ui contains the static method convertSize that can be used, as you might have guessed, for size conversion between different measurement units. We'll of course convert our measurements to pixels, because that's the unit expected by most drawing methods. But what unit will we convert from?

Points are nice, because you probably use them for your font size already, but they are to coarse to be used for all components. Fortunately there is no need to write a wrapper for your own unit, because you can use built-in unit called centipoints. 100 centipoints = 1 point, so this unit should provide enough precision to layout elements just the way you want.
