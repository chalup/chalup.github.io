---
layout: post
comments: true
title: "Android App Widgets issues"
date: 2014-05-10T15:42:00+02:00
categories:
 - App Widget
 - Android
---

This week I spend few days analyzing and fixing various issues of app widget in Base CRM application.

This part of our codebase was created over a year ago during one of our internal hackathons and was released soon after that. Most of the times it worked. Every once in a while we received a weird crash report from Google Analytics, but it never caused much trouble. Recently though we received few complaints from customers. I happened to have few hours available for bug hunting, so I took a dive.

The widget is really a simple todo list backed by `ContentProvider`. The code looks like it was based on the WeatherWidget from SDK samples. What can possibly go wrong?

## Issue #1: gazillions of threads started

Take a look at the code of WeatherWidgetProvider: 
``` java
public WeatherWidgetProvider() {
  // Start the worker thread
  sWorkerThread = new HandlerThread("WeatherWidgetProvider-worker");
  sWorkerThread.start();
  sWorkerQueue = new Handler(sWorkerThread.getLooper());
}
```

The WeatherWidgetProvider is an `AppWidgetProvider` implementation, which extends a regular `BroadcastReceiver`. It means that for every action a new instance of WeatherWidgetProvider is created, and the current implementation spawns new thread which is never closed.

The sample author obviously intended to create only one worker thread - the sWorkerThread is the static - but forgot to do the null check before creating a new thread. So let's fix it:
``` java
public WeatherWidgetProvider() {
  if (sWorkerThread == null) {
    // Start the worker thread
    sWorkerThread = new HandlerThread("WeatherWidgetProvider-worker");
    sWorkerThread.start();
    sWorkerQueue = new Handler(sWorkerThread.getLooper());
  }
}
```

## Issue #2: no refresh after application update
The widget shows data from the same `ContentProvider` as the main app, so when the user creates a task inside in the main app and then goes back to homescreen, the task should be displayed on the widget. To achieve this we did the same thing the WeatherWidget sample does - we register the `ContentObserver` in `onEnabled` callback of `AppWidgetProvider`:

``` java
@Override
public void onEnabled(Context context) {
  final ContentResolver r = context.getContentResolver();
  if (sDataObserver == null) {
    final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
    final ComponentName cn = new ComponentName(context, WeatherWidgetProvider.class);
    sDataObserver = new WeatherDataProviderObserver(mgr, cn, sWorkerQueue);
    r.registerContentObserver(WeatherDataProvider.CONTENT_URI, true, sDataObserver);
  }
}
```

The `onEnabled` callback is called when the first instance of the widget is added to homescreen, so the code looks fine. Unfortunately the callback is not called at your process startup. So if your app is updated and the process is restarted, the `ContentObserver` won't be registered. The same thing happens if your app crashes or is stopped by the OS to free resources.

To solve this you have to register the `ContentObserver` in few more places. I have added registration to `onCreate` callback in `RemoteViewsFactory` and the `onReceive` part which handles our custom actions in `AppWidgetProvider`.

WeatherWidget sample does one more thing wrong: the `ContentObserver` is never unregistered and the worker thread is never stopped. The correct place to do this is `onDisabled` callback in `AppWidgetProvider`.

## Issue #3: `CursorOutOfBoundsException` crash
Ever since we introduced the tasks widget, we've occasionally received the crash reports indicating that the RemoteViewsFactory requested elements outside of `[0, getCount)` range:

```
05-10 15:22:50.559  13781-13795/org.chalup.widgetfail.widget E/AndroidRuntime﹕ FATAL EXCEPTION: Binder_2
    Process: org.chalup.widgetfail.widget, PID: 13781
    android.database.CursorIndexOutOfBoundsException: Index 1 requested, with a size of 1
```

The reproduction steps for this issue are quite complicated:

* Tap the task on the widget to mark it was completed. Internally we set the `PENDING_DONE` flag, so the task is marked as done, but is still displayed on the list, so the user can tap it again and reset the flag.
* Trigger the sync
* `SyncAdapter` syncs the Task to our backend. The task is marked as `DONE` in our database, which triggers the `ContentObserver` registered by the widget.
* `ContentObserver` triggers `onDataSetChanged` callback in `RemoteViewsFactory`, which then calls `getCount` and `getViewAt`
* In some rare cases `getViewAt` with position == result of `getCount` is called

It looks like some kind of a race condition or another threading issue in Android code which populates the app widgets. I tried synchronizing the `RemoteViewsFactory` methods, but it didn't help. The `getViewAt` have to return a valid `RemoteViews`, so I fixed it up by returning the loading view when element outside of valid range is requested:

``` java
@Override
public synchronized RemoteViews getViewAt(int position) {
  if (position >= mCursor.getCount()) {
    return getLoadingView();
  } else {
    mCursor.moveToPosition(position);

    // ...
  }
}
```

## Issue #4: no refresh when "Don't keep activities" setting is enabled
User can click on the tasks displayed on the widget to go to the edit screen. The activity is closed when user saves or discards changes and the homescreen with the widget is shown again. Changing the task triggers the `ContentObserver`, the `onDataSetChanged` is called on all active `RemoteViewsFactories`, but sometimes other callbacks (`getCount`, `getViewAt`, etc.) are not called.

It turns out this happens when the Homescreen activity is recreated because of low memory condition. To easily reproduce this issue you can check the "Don't keep activities" in developers settings.

I do not have a solution or workaround for this issue unfortunately. I'll file a bug report and hope for the best.

## Recap
There are mutliple issues with the WeatherWidget sample and some issues with the system services responsible for populating app widgets with content. I've created a simple project which reproduces the issues #3 and #4 and shows the correct way of registering `ContentObserver` for your widget. The sources are [available on Github](https://github.com/chalup/android-widget-fail).
