---
layout: post
title: "Google I/O 2014 summary"
date: 2014-06-27 21:34:11 +0200
comments: true
categories: 
 - Android
 - I/O
---

Here are my thoughts after watching the keynote and few Android related sessions.

## Highlights

### Android One
This might be a huge, not only because it means expanding the potential user base for your apps. The most important thing is that all these new devices will run the latest Android and software updates will be provided by Google. If this kind of support becomes standard, we might be able to use `minSdkVersion=20` pretty soon.

### ART
The Dalvik was decomissioned, the new runtime is the only runtime. I do hope this means that the 64k method limit is no longer a problem and there are no technical roadblocks for Java 8 support. Maybe this questions were answersed during [The ART runtime](https://www.google.com/events/io/schedule/session/b750c8da-aebe-e311-b297-00155d5066d7) session, unfortunately there was no live stream of it.

**Edit**: the video from the session is available. The GC improvements and performance boosts are amazing, but if I understand everything correctly the ART still uses dex bytecode underneath, so all Dalvik limitations are still in place.	Bad Google.

### [+Xavier Ducrohet](https://plus.google.com/+XavierDucrohet/posts)
I got the feeling that he's the only Google employee who acknowledges that there are serious issues with developing on Android. Great answers about unit tests and robolectric support, good answer about Scala support.

## Dunno what to make of it

### RecyclerView
`ListViews` are far from perfect. I know, because in our codebase we have few workarounds for the issues or poor APIs. It's good that something more flexible is available, it's great that it's a part of support library, but some parts of the `RecyclerView` API look incredibly complex.

### Unlock bypass with Wear device
Call me paranoid, but this feature means that if I get mugged, I'm totally screwed. Someone gets access to my email, and through that he gets access to every piece of my data on the web and my digital idendity. Thanks, I'll pass.

On the other hand there are users who do not use pin or pattern on the lockscreens. For these people, this feature is a significant security improvement.

## Lowlights

### Always running, big-ass TVs
During keynote one speaker mentioned that in average household the TV is on for 5 hours every day and suggested that for the other 19 hours it can be used as a digital canvas for your content. I'm not sure if encouraging people to keep the huge, power hungry device all the time to display nice pictures is very thoughtful and enviromentally aware.

### Fireside chat
There were some über lame questions from the audience, but that's expected when questions are not moderated. However there were also über lame answers for valid questions, and there is no excuse for it.

The very first question, about Java 8 support, was answered with smirks and a slimy answer from Chet Haase. Dear Google, after WWDC the Java 8 support is no longer a huge news, so if you're saving it for the future, don't bother. And if there are any issues with Java 8 support - legal, technical, whatever - just let the developers know.