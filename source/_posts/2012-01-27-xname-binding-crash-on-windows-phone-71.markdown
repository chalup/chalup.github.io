---
layout: post
title: "x:name binding crash on Windows Phone 7.1"
date: 2012-01-27T11:29:00+01:00
categories:
 - Windows Phone
 - Xaml
 - Rant
---


Recently I've started working on the new version of Windows Phone application originally written by interns in my company. One of the first tasks was to migrate from WP 7.0 to 7.1, a.k.a. "Windows Phone 7.5" (because 7.5 sounds sooooo much better than 7.1), a.k.a. "Windows Phone Mango". The transition was generally smooth and it seems we'll be able to clean up some 7.0 specific workarounds, but there was one crash that was quite tricky to track down:

``` c#
Null Reference Exception:
    at MS.Internal.XcpImports.CheckHResult(UInt32 hr)
    at MS.Internal.XcpImports.UIElement_Measure_WithDesiredSize(UIElement element, Size availableSize)
    at System.Windows.UIElement.Measure_WithDesiredSize(Size availableSize)
    at System.Windows.Controls.VirtualizingStackPanel.MeasureChild(UIElement child, Size layoutSlotSize)
    at System.Windows.Controls.VirtualizingStackPanel.MeasureOverride(Size constraint)
    ...
```

Our code wasn't even in a call stack! It turns out that the following code worked on 7.0, but crashed on newer version:

``` xml
<validationcontrol:validationcontrol
    grid.row="1"
    inputscope="Number"
    lostfocus="OnCustomValueChanged"
    text="{Binding Custom}"
    width="420"
    x:name="{Binding Key}"/>

```

I'm not sure if using binding for a control name and relying on that information in code behind is a good idea, but I'm damn sure it shouldn't crash. And even if it crashes, it should provide some useful information instead of throwing NRE from seemingly random place.

What's the fix for it? Use x:Tag instead of x:Name.
