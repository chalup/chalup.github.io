---
layout: post
comments: true
title: "When do you absolutely need WakefulBroadcastReceiver"
date: 2014-02-20T10:24:00+01:00
categories:
 - Android
 - Protip
---

[Yesterdays #AndroidDev #Protip](https://plus.google.com/108967384991768947849/posts/i6MzCp1NyzF) explains how to use [`WakefulBroadcastReceiver`](http://developer.android.com/reference/android/support/v4/content/WakefulBroadcastReceiver.html) utility class and what problem does it solve, but it doesn't mention a case when using it or manually acquiring [`WakeLock`](http://developer.android.com/reference/android/os/PowerManager.WakeLock.html) is essential - using the [`AlarmManager`](http://developer.android.com/reference/android/app/AlarmManager.html).

If you're not familiar with `AlarmManager`'s API, here is **tl;dr** of the docs: it allows you to specify the [`PendingIntent`](http://developer.android.com/reference/android/app/PendingIntent.html) that should be fired at some point, even if your application is in background. The common use cases for using [`AlarmManager`](http://developer.android.com/reference/android/app/AlarmManager.html) is for example showing a [`Notification`](http://developer.android.com/reference/android/app/Notification.html) at the specified time or sending some kind of heartbeat to your backend. In both cases, your code performs potentially long running operation (in case of showing notification you might need some content from your local database), so you don't want to run it in the UI thread. The first thing that comes to mind is to specify an [`IntentService`](http://developer.android.com/reference/android/app/IntentService.html) as a [`PendingIntent`](http://developer.android.com/reference/android/app/PendingIntent.html) target:

``` java
PendingIntent intent = PendingIntent.getService(
  context, 
  0,
  new Intent(context, MyIntentService.class),
  PendingIntent.FLAG_UPDATE_CURRENT
);

AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
alarmManager.set(
  AlarmManager.ELAPSED_REALTIME_WAKEUP,
  SystemClock.elapsedRealtime() + TimeUnit.MINUTES.toMillis(15)
  intent
);
```

This code won't always work though. While it is guaranteed that the alarm will go off and the [`PendingIntent`](http://developer.android.com/reference/android/app/PendingIntent.html) will be sent, because we used a `_WAKEUP` alarm type, the device is allowed to go back to sleep before the service is started.

{% img center /images/wakelock.001.png %}

It's not explicitly documented, but both [+Dianne Hackborn](https://plus.google.com/105051985738280261832) and [+CommonsWare](https://plus.google.com/114205433913370454414) [confirmed](https://groups.google.com/d/msg/android-developers/K5ggbRigGS8/B5KajJYAae4J) [this](http://stackoverflow.com/a/7444510/184953). The workaround is to use [`PendingIntent.getBroadcast()`](http://developer.android.com/reference/android/app/PendingIntent.html#getBroadcast%28android.content.Context, int, android.content.Intent, int%29), because it is guaranteed that the [`BroadcastReceiver.onReceive()`](http://developer.android.com/reference/android/content/BroadcastReceiver.html#onReceive%28android.content.Context, android.content.Intent%29) will be always fully executed before the CPU goes to sleep. Inside that callback you have to acquire [`WakeLock`](http://developer.android.com/reference/android/os/PowerManager.WakeLock.html) start your [`IntentService`](http://developer.android.com/reference/android/app/IntentService.html) and release the lock at the end of [`onHandleIntent()`](http://developer.android.com/reference/android/app/IntentService.html#onHandleIntent%28android.content.Intent%29) method.

{% img center /images/wakelock.002.png %}

This is where the [`WakefulBroadcastReceiver`](http://developer.android.com/reference/android/support/v4/content/WakefulBroadcastReceiver.html) comes into play: its [`startWakefulService`](http://developer.android.com/reference/android/support/v4/content/WakefulBroadcastReceiver.html#startWakefulService%28android.content.Context, android.content.Intent%29) and [`completeWakefulIntent`](http://developer.android.com/reference/android/support/v4/content/WakefulBroadcastReceiver.html#completeWakefulIntent%28android.content.Intent%29) static methods encapsulate all the [`WakeLocks`](http://developer.android.com/reference/android/os/PowerManager.WakeLock.html) juggling, allowing you to focus on your business logic.
