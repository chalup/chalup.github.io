---
layout: post
comments: true
title: "QML error handling revisited"
date: 2012-03-28T23:01:00+02:00
categories:
 - QML
 - Qt
---

After releasing [Nu, Pogodi!](http://store.ovi.com/content/219800) I learned the hard way that checking the QML runtime errors might be a good idea. For that particular application, simply checking the errors from `QDeclarativeView` after setting the main qml file was enough, because everything in qml file was statically declared. But what if you use [QML Loader](https://qt-project.org/doc/qt-4.8/qml-loader.html) element, either explicitly or through some other qml element like [PageStack from Qt Components](http://doc.qt.nokia.com/qt-components-symbian/qml-pagestack.html), and something goes wrong?

Well, if you don't improve the error handling code, your application will silently fail in some places, which probably won't make the users happy. I didn't wanted to repeat the [Nu, Pogodi!](http://store.ovi.com/content/219800) screw up when releasing [Word Judge](http://store.ovi.com/content/262535), so I've created a better error handling solution. First part is an error handler class:

``` cpp
// ----------------------------------------
//  qmlerrorhandler.h
// ----------------------------------------

class QmlErrorHandler : public QObject
{
    Q_OBJECT
public:
    explicit QmlErrorHandler(QDeclarativeView &view, QObject *parent = 0);
    bool errorOccured() const;

private slots:
    void handleQmlStatusChange(QDeclarativeView::Status status);
    void handleQmlErrors(const QList<QDeclarativeError>& qmlErrors);

private:
    QDeclarativeView &mView;
    bool mErrorOccured;

};

// ----------------------------------------
//  qmlerrorhandler.cpp
// ----------------------------------------

QmlErrorHandler::QmlErrorHandler(QDeclarativeView &view, QObject *parent) :
    QObject(parent),
    mView(view),
    mErrorOccured(false)
{
    connect(&view, SIGNAL(statusChanged(QDeclarativeView::Status)), SLOT(handleQmlStatusChange(QDeclarativeView::Status)));
    connect(view.engine(), SIGNAL(warnings(QList<QDeclarativeError>)), SLOT(handleQmlErrors(QList<QDeclarativeError>)));
}

void QmlErrorHandler::handleQmlStatusChange(QDeclarativeView::Status status)
{
    if (status == QDeclarativeView::Error) {
        handleQmlErrors(mView.errors());
    }
}

void QmlErrorHandler::handleQmlErrors(const QList<QDeclarativeError>& qmlErrors)
{
    QStringList errors;
    foreach (const QDeclarativeError& error, qmlErrors) {
        // Special case for bug in QtComponents 1.1
        // https://bugreports.qt-project.org/browse/QTCOMPONENTS-1217
        if (error.url().toString().endsWith("PageStackWindow.qml") && error.line() == 70)
            continue;

        errors.append(error.toString());
    }

    if (errors.isEmpty())
        return;

    mErrorOccured = true;

    QMessageBox msgBox;
    msgBox.setText("Uh oh, something went terribly wrong!");
    msgBox.setInformativeText("We're sorry, but it seems there are some problems "
                              "with running our application on your phone. Please "
                              "send us the following information to help us resolve "
                              "this issue:\n\n") +
                              errors.join("\n"));
    msgBox.exec();
    qApp->exit(-1);
}

bool QmlErrorHandler::errorOccured() const
{
    return mErrorOccured;
}
```

And here's how I use it in my applications:

``` cpp
int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());
    QmlErrorHandler errorHandler(*viewer);
    viewer->setMainQmlFile(QLatin1String("main.qml"));
    viewer->showExpanded();

    if (!errorHandler.errorOccured()) {
        return app->exec();
    } else {
        return -1;
    }
}
```

Basically we need to catch the runtime errors, which are emitted from `QDeclarativeEngine` in signal named for some unfathomable reason `warnings`. Checking the `errorOccured()` in `main()` is ugly, but the `qApp->exit()` doesn't work until the event loop in main is started and that's the first thing which came to my mind. Please leave a comment if you know a simpler solution.

Note the lines 46-49 in `QmlErrorHandler`: we're catching all warnings and the qt components are not completely free of them. I had to add a special case to prevent triggering the handler on every orientation change. If you stumble upon some other errors that should be ignored, please let me know.
