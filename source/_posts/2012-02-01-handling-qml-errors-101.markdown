---
layout: post
comments: true
title: "Handling QML errors 101"
date: 2012-02-01T12:02:00+01:00
categories:
 - QML
 - Qt
---


Qt SDK comes with great documentation and examples, but there is hardly any information about handling QML errors. All examples assume that nothing can go wrong during runtime, which is a bit naive approach. Even if your app is completely bug free, the users will find a way to shoot themselves in the foot. They will install your app and then uninstall key plugins ignoring all warnings from system. They will install your app on SD card and then delete some files for some unfathomable reason. And then they will blame you. 

Let's consider what happens if you have an error in your main QML file? User sees the black screen, gets pissed off, uninstalls your app and gives it a negative review in Nokia store. Not good. Let's try something different: 

``` cpp
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);   
    QDeclarativeView canvas;

    canvas.setSource(QLatin1String("main.qml"));
    if (!canvas.errors().empty()) {
        // handle errors
        QMessageBox msgBox;
        msgBox.setText("Uh oh, something went terribly wrong!");
        msgBox.setInformativeText(
            "We're sorry, but it seems there "
            "are some problems with running "
            "our application on your phone.");
        msgBox.exec();

        return -1;
    }

    // optionally set the screen orientation
    // call show/showFullscreen/showMaximized

    return app.exec();
}

```

Few notes about the snippet above:

* If you're using the QML Application template from the recent version of Qt Creator you probably have a generated QmlApplicationViewer class instead of raw QDeclarativeView, but the general idea stays the same.
* Error handling section above is only a stub. You may ask user to reinstall the application. You may display more information about the error along with some contact information. If your application uses network connection, you should probably ask user if he wants to send an error report.
* If you use the QMessageBox or other modal dialog and lock the screen orientation, you mustn't lock the orientation before showing the dialog. In current version of Qt (4.7.4) there is a bug and in case of forced orientation change only dialog buttons are displayed.
