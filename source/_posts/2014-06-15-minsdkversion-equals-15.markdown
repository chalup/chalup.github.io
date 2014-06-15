---
layout: post
title: "minSdkVersion=15, what's next?"
date: 2014-06-15 09:29:50 +0200
comments: true
categories: 
 - Android
 - minSdkVersion
---

A year ago [Jeff Gilfelt](https://twitter.com/readyState) was giving away `minSdkVersion=14` stickers, promoting the idea of dumping the support for Gingerbread and Honeycomb. What seemed radical one year ago, today is a widely accepted. The `minSdkVersion` in new project wizard in latest Android Studio release is by default set to `15`. On the same screen you can click the "help me choose" hyperlink, which shows this screen:

{% img center /images/android_studio_min_sdk.png %}

The percentages are consistent with data from [developer.android.com](http://developer.android.com/about/dashboards/index.html) dashboards, but I'd say they are skewed towards old Android versions. [Base CRM](https://play.google.com/store/apps/details?id=com.futuresimple.base) app I'm working on has only 3.7% active users on devices with api level < 15 (compared to 17.4% from official Google dashboards). Moreover, if you look only at the new users, the Froyo, GingerBread and Honeycomb is used only by 1%. In this light, supporting pre-API15 devices is a criminal waste, and starting new projects with minSdkVersion lower than 15 a criminal idiocy.

For me, as a delevoper, the `minSdkVersion=14` is a breakthrough, mostly because of Holo theme available everywhere. I no longer have to worry about [HTC rounded green buttons and such when creating custom views](http://localhost:4000/blog/2012/03/08/customizing-ui-controls-on-android/) - I only have to make them look good with a single theme. Theoretically one could have used [HoloEverywhere lib](https://github.com/Prototik/HoloEverywhere), but it's not a drop-in replacement. First you have to switch to using their Views instead of native ones and adjusting any external UI library to use them as well.

I looked through the [Android changelogs](https://developer.android.com/about/index.html) wondering what could be the next version on `minSdkVersion` stickers. The next step is a small bump to JellyBean (API level 16), which gives us access to actions in system notifications and `condensed` and `light` Roboto font variants. Official statictics state that Ice Cream Sandwich is used by 12.3% of users, but this number is much higher than the one from Base statistics - 5.87%. I expect dropping support for ICS this year.

But then? I don't see anything as groundbreaking as dropping Gingerbread. I don't even see anything with more impact than dropping ICS. Theoretically API level 17 gives access to nested fragments, but I think you should be using support-v4 classes anyways (and if you check the [Google I/O 2014](https://play.google.com/store/apps/details?id=com.google.samples.apps.iosched) app sources, Google developers seem to think so too). Maybe there's something I missed or something crucial for specific use cases - do let me know if there's anything in API levels 17-19 you wish you could use already.

Google I/O is coming though, and [some things indicate](https://twitter.com/GabMarioPower/status/477040313832583168) we might see Android 5.0 (or at least Android 4.5). Maybe this Android "L" version will be another breakthrough in development? My personal wish is a new runtime without [ridiculous 64k method limit](https://code.google.com/p/android/issues/detail?id=20814). Of course this opens a lot of other possibilities. Maybe support for Java 8? Or first-class support for other JVM languages? We'll see...