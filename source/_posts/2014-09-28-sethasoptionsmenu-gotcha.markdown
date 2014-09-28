---
layout: post
title: "setHasOptionsMenu gotcha"
date: 2014-09-28 23:31:57 +0200
comments: true
categories: 
 - Android
 - gotcha
---
When your `Fragment` puts some actions in the action bar, it should call `setHasOptionsMenu(true)`. And where should you make this call? You probably follow samples and call it from `onCreate()` callback.

Later you decide to hide one of the actions under certain circumstances. The way do to this is to implement `onPrepareOptionsMenu(Menu)` callback and alter the `Menu` object passed as an argument.

If you are not careful, depending on the visibility precondition you apply, you might have implemented instant crash on OS versions before Jelly Bean. On API level 17, the `onPrepareOptionsMenu` is called from runnable posted on some handler; on older versions the menu callbacks are called synchronously, so they are really called from `onCreate()`, which means that your Fragment is not yet fully initialized.

What's the takeaway? Always test your app on wide variety of devices and OSes before the release and do not trust official Android samples.