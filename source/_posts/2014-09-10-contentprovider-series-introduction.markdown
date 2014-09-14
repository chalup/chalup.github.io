---
layout: post
title: "ContentProvider series - Introduction"
date: 2014-09-10 21:25:19 +0200
comments: true
categories:
 - Android
 - ContentProvider
---
One of the first section of Android [API Guides](http://developer.android.com/guide/index.html) is the description of different app compontents. New developers can read about Activities, which map directly to app UI, about Services, which perform background tasks, about BroadcastReceivers, which let's your app react to different system events, etc. At some point they read about ContentProvider and they think:

{% blockquote %}
Why would I want to use it?
{% endblockquote %}

Android documentation give two reasons: when you want to share data with other applications; or when you want to integrate with search framework. I'd say these use cases do not apply to most of the Android applications out there, but there are other resasons for using ContentProviders.

Database handle management
--------------------------
Let's say you don't use ContentProvider, but you want to use the SQLite database to store your data. Most likely you'll end up with the `SQLiteOpenHelper` singleton in your `Application` object with some helper methods. Easy to code, but it's really reimplementation of `Context.getContentResolver()`.

Encapsulation
-------------
If you go with the solution described above, you'll operate directly on the `SQLiteOpenHelper` or `SQLiteDatabase` objects and if you're not careful, this implementation detail will leak across your application. Ideally you should create an abstraction around it, but then you'll end up with something like ContentProvider anyways.

When in Rome, do as the Romans do
---------------------------------
The ContentProvider API is leaked throughout the Android SDK. Whether it's good or bad thing is a topic for another blog post, but the facts stay the same. If you decide not to use the ContentProvider, you forego publish-subscribe mechanism provided by `CursorLoaders` (**tl;dr:** you can set up automatic reload of data on the UI when the data is updated), `SyncAdapter` framework with built-in throttling, etc. You can implement all of this on your own, but you probably should focus on your business logic and UX instead of rewriting Android SDK.

IPC
---
As in "Inter-process communication". I haven't seen this point raised in any ContentProvider discussions, but the ContentProvider can be moved to separate process (if you don't do some smelly things like accessing singletons) or accessed from any other processes in your application. And why would you want to do this?

If you don't do some brain-dead stupid things, the biggest source of animation jank in your application is garbage collection pauses. This problem is partially solved by GC improvements in ART in Android L, but let's face it - I don't expect will be `minSdkVersion=20` before the end of 2016. Until then we need another solution.

Since GC is performed per-process, one thing you can do is moving your memory intensive operations - like web API access and JSON parsing - to another process. But if you want to access your database from another process you can't use `SQLiteOpenHelper` singleton. You'll have to access it through some IPC mechanism. ContentProvider gives you this for free.

Summary
-------
There are more to ContentProviders than you can see in the official documentation or top 5 hits on Google search. Actually, this is the first post in the upcoming series of posts in which I'll describe some other aspects of ContentProvider implementation like content Uris design, thread safety, ContentProvider API deficiencies, documentation samples suckage and some solutions that can make implementing ContentProviders less painful. Stay tuned!