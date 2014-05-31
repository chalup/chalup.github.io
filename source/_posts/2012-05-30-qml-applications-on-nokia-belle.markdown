---
layout: post
title: "QML applications on Nokia Belle"
date: 2012-05-30T20:06:00+02:00
categories:
 - Nokia
 - QML
 - Qt
---


After the latest update of "Nu, Pogodi!", I received few negative reviews saying that the game doesn't work. I've tested the game thoroughly on all devices I was able to get my hands on, but I wasn't able to reproduce the error, so I decided to wait until I get more info. Few days ago with the help of one customer I was able to pin down the problem - the game failed to display any UI on new Belle firmware with Qt 4.8.0. I don't have such device myself, but fortunately the great [Remote Device Access](http://www.developer.nokia.com/Devices/Remote_device_access/) service allows testing on Nokia 808 PureView with latest Belle firmware. I've reproduced the error, wrote the Nokia Developers Support, and they sent me a very helpful link: [Changes in Nokia Belle FP1](http://www.developer.nokia.com/Community/Wiki/Changes_in_Symbian_Belle_and_Qt_4.7.4#Changes_in_Nokia_Belle_FP1). One issue listed there caught my eye:

{% blockquote %}
If application does not specify a size for the root QML object and doesn’t use the Qt components Window as root element (Window component should not be used as a child item), it might cause the root window not to be shown.

<b>Solution / Workaround:</b>
Always declare a size for your custom QML root element.
{% endblockquote %}

I've checked my main QML file and indeed, I did not set the root element size, instead I've set the resize mode to SizeRootObjectToView and maximized the QDeclarativeView. I think it's the better solution than setting the root element size explicitly, because the display resolution is not the same on all Nokia phones (I'm looking at you, E6). Instead of doing that, I wrapped my entire UI into Window element from Qt Components and lo and behold, my game displayed something, although it wasn't exactly what I expected:

{% img center /images/Nokia+808+PureView.png %}

My code locked the screen orientation after loading main QML file, and it looked like the only thing that might cause this problem, so I changed the calls order. On Belle FP1 devices everything worked fine, but this change broke the display on devices with Anna and older Belle firmware:

{% img center /images/Nokia+N8-00.png %}

Wat? The only solution I came up with was creating the utility method for detecting version of Qt during runtime and locking screen orientation after and before loading main QML file, depending on the Qt version. Relevant piece of code:

``` c++
bool Utils::runtimeQtAtLeast(int major, int minor, int bugfix)
{
    const QStringList v = QString::fromAscii(qVersion()).split(QLatin1Char('.'));
    if (v.count() == 3) {
        int runtimeVersion = v.at(0).toInt() << 16 | v.at(1).toInt() << 8 | v.at(2).toInt();
        int version = major << 16 | minor << 8 | bugfix;
        return version <= runtimeVersion;
    }
    return false;
}

// ...

const bool qt48 = Utils::runtimeQtAtLeast(4,8,0);
QmlApplicationViewer viewer;
if (qt48) {
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockLandscape);
    viewer.setResizeMode(QDeclarativeView::SizeRootObjectToView);
}

viewer.setMainQmlFile(QLatin1String("qml/nupagadi/GameArea.qml"));

if (!qt48) {
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockLandscape);
    viewer.setResizeMode(QDeclarativeView::SizeRootObjectToView);
}
```

This kind of incompatibility between **minor** versions of the Qt framework is mind boggling. It makes me think what else did Nokia screw up in Qt 4.8.0 for Symbian and what will they screw up in the next firmware updates. One thing is sure: I'll have a lot of blogging material.
