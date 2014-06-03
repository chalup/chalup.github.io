---
layout: post
comments: true
title: "Screensaver blocking on Symbian"
date: 2012-10-03T20:55:00+02:00
categories:
 - Game
 - Nokia
 - QML
 - Printer 1D
 - Symbian
 - Qt
 - Qt Mobility
---

In my [latest game](http://store.ovi.com/content/318428) the players spend significant amount of time just watching the screen and trying to figure the puzzle out. The first few levels are obvious and most players will sole them in a few seconds, but as the difficulty of the puzzles increases the players stare at the screen longer and longer. At some point the screensaver would kick in and piss the player off (fortunately my ragtag QA/betatester team found this issue before launch).

[Google search results](https://www.google.com/search?q=how+to+block+screensaver+symbian+qt) are (as usual) helpful, but the most promising lead, the [`QSystemScreenSaver`](http://doc.qt.digia.com/qtmobility/qsystemscreensaver.html) class is not a solution. There are three problems with it:


1. The API of the class itself is terrible.
1. The API of the [related QML element](http://doc.qt.digia.com/qtmobility/qml-screensaver.html) is even worse.
1. Last, but not least, it doesn't work (at least not in the Qt Mobility version shipped with the Qt SDK).

(BTW: these three points sums up pretty much every experience with Qt Mobility package I had. Qt devs should either kill this festering boil with fire or fix it and rename it, because I learned to dread everything remotely related to Qt Mobility, and I suspect I'm not the only one).

Anyways, let's get back to the core of the problem, i.e. "how to block the screensaver". Qt Mobility failed, but the task doesn't seems like a rocket science to me. [Slightly different Google search](https://www.google.com/search?q=how+to+block+screensaver+s60+c%2B%2B) suggested using native Symbian's [`User::ResetInactivityTime()`](http://library.developer.nokia.com/topic/Nokia_Belle_Developers_Library/GUID-C6E5F800-0637-419E-8FE5-1EBB40E725AA/GUID-C197C9A7-EA05-3F24-9854-542E984C612D.html#GUID-A98E1B31-00E0-3DF1-8D5A-8E815B073D81) method. Few minutes and one `QTimer` later, everything worked:

``` c++
#ifndef SCREENSAVERBLOCKER_H
#define SCREENSAVERBLOCKER_H

#include <QObject>
#include <QApplication>
#include <QTimer>

class ScreenSaverBlocker : public QObject
{
    Q_OBJECT

public:
    explicit ScreenSaverBlocker(QObject *parent = 0) : QObject(parent) {
        mTimer.setInterval(1000);
        connect(&mTimer, SIGNAL(timeout()), this, SLOT(blockScreenSaver()));
        changeScreenSaverState(QApplication::activeWindow() != 0);
        if (qApp) {
            qApp->installEventFilter(this);
        }
    }

    void changeScreenSaverState(bool blockScreenSaver) {
        if (blockScreenSaver && !mTimer.isActive()) {
            mTimer.start();
        } else {
            mTimer.stop();
        }
    }

protected:
    bool eventFilter(QObject *obj, QEvent *event) {
        Q_UNUSED(obj)
        if (event->type() == QEvent::ApplicationActivate
         || event->type() == QEvent::ApplicationDeactivate) {
            changeScreenSaverState(event->type() == QEvent::ApplicationActivate);
        }
        return false;
    }

private slots:
    void blockScreenSaver() {
#ifdef Q_OS_SYMBIAN
        User::ResetInactivityTime();
#endif
    }

private:
    QTimer mTimer;
};

#endif // SCREENSAVERBLOCKER_H
```

The important thing in the code above is watching the `ApplicationActivate` and `ApplicationDeactivate` events - after all, when your app is in background, you shouldn't affect the phone behavior. I'm not sure if the app would fail the Nokia's QA process without this feature, but it seemed prudent to write the code this way.

If you want to use this object in your QML UI just register it with [`qmlRegisterType`](http://doc.qt.digia.com/4.7/qdeclarativeengine.html#qmlRegisterType) and add the registered import and QML element to your root element.
