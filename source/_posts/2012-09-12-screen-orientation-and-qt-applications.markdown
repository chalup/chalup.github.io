---
layout: post
title: "Screen orientation and QT applications on Symbian Belle"
date: 2012-09-12T22:05:00+02:00
categories:
 - Nokia
 - Nokia Store
 - QML
 - Symbian
 - Qt
---

Let's take a break from [Android](/blog/2012/08/30/custom-scrollbar-graphics-in-android) [gotchas](/blog/2012/09/05/android-sharedpreferences-gotcha) and do some mobile necrophilia, i.e. let's talk about Symbian.

Recently I received an email from Nokians saying that they are testing Nokia Store content with new firmware update and [my app](http://store.ovi.com/content/219800) won't work after update. After few quick email exchanges we narrowed down the problem to [screen orientation locking code I wrote about some time ago](/blog/2012/05/30/qml-applications-on-nokia-belle). It turns out that things can be done much simpler:

``` js
Window {
    Rectangle {
        id: root
        anchors.fill: parent

        Component.onCompleted: {
            screen.allowedOrientations = Screen.Landscape
        }

        // more stuff
    }
}
```

``` c++
int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    QmlApplicationViewer viewer;
    viewer.setMainQmlFile(QLatin1String("qml/nupagadi/GameArea.qml"));
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockLandscape);
    viewer.setResizeMode(QDeclarativeView::SizeRootObjectToView);
    viewer.showExpanded();

    return app->exec();
}
```

Less code, no need to comment it as a gotcha/workaround, and it's supposedly futureproof.

I'm very positively surprised with Nokians' approach, responsiveness and this whole experience. Of course I wouldn't be me if I didn't bitch a little bit, namely: why did I have this problem in the first place? I mean, locking the screen orientation is not a rocket science and should be well documented. It should, but unfortunately it's not, like so many things about QML.
