---
layout: post
comments: true
title: "Upgrading to Android SDK Tools revision 22"
date: 2013-05-22T23:31:00+02:00
categories:
 - Android
 - build system
---

The Google I/O 2013 has come and gone and one of the many things left in its wake is the new revision of Android SDK Tools and ADT plugin for Eclipse. If you haven't let Eclipse go in favor of new hot [Android Studio](http://developer.android.com/sdk/installing/studio.html) (which is what Mark Murphy, a.k.a. commons guy, [recommends](http://commonsware.com/blog/2013/05/16/android-studio-early-access-preview-and-you.html) BTW) and you upgraded to the latest Android SDK Tools, you'll probably have some issues with building your old projects.

After installing all the updates from Android SDK Manager and updating the ADT Eclipse plugin your projects will simply fail to build, with the errors pointing to the R class in gen folder. If you try to build the project with ant you'll get more meaningful "no build tools installed" message. After re-running the Android SDK Manager, you should see an additional item in Tools section called Build-tools. Go ahead and install it.

Now your project will build (you might have to restart the Eclipse), but if you use any external libraries from your projects libs directory, your app will crash on the first call using this libs. To fix this you have to go to the project Properties, Java Build Path, Order and Export tab and check the "Android Private Libraries" item. The previous name for this item was "Android Dependencies" and apparently the build rules for those two are not updated correctly.

Of course new projects created with revision 22 of Android tools doesn't require jumping through all those hoops.
