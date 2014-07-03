---
layout: post
title: "Android recent apps list and Intent extras"
date: 2014-07-03 22:14:06 +0200
comments: true
categories: 
 - Android
 - gotcha
---
If you're programming for the same platform for some time, you have probably developed some habits. You do some stuff in a particular way, because you've always done it this way. It might be a good thing if you know all pros and cons of your solution, because your code will be consistent and you don't waste time rethinking the same things over and over again. On the other hand it is a good practice to question this established ways of doing things from time to time - maybe you've missed something when you thought about this last time or some of your arguments are no longer valid.

For me one of such things was the `Serializable` vs. `Parcelable` conundrum. A long time ago I read somewhere that `Serializable` is much slower than `Parcelable` and it shouldn't be used for large objects, but it's fast enough for passing simple POJOs between `Fragments` and `Activities` with `Intent` or arguments `Bundle`. While this is still a generally good advice, I realized I don't know how much faster the `Parcelable` is. Are we looking at 10µs vs. 15µs or 10µs vs. 10ms?

I'm too lazy to write a benchmark myself, but I found a [decent article](http://www.developerphil.com/parcelable-vs-serializable/). Tl;dr: on modern hardware (Nexus 4) serializing a simple data structure takes about 2ms and using `Parcelable` is about 10 times faster.

Another hit on Google was a [reddit thread](http://www.reddit.com/r/androiddev/comments/1daiib/parcelable_vs_serializable/) for this article. I found there an interesting comment by [+Jake Wharton](https://plus.google.com/u/1/+JakeWharton):

{% blockquote %}
Serializable is like a tattoo. You are committing to a class name, package, and field structure forever. The only way to "remove" it is epic deserialization hacks.

Yes using it in an Intent isn't much harm, but if you use serialization there's a potential for crashing your app. They upgrade, hit your icon on the launcher, and Android tries to restore the previous Intent for where they were at in your app. You changed the object so deserialization fails and the app crashes. Not a good upgrade experience. Granted this is rare, but if you ever persist something to disk like this it can leave you in an extremely bad place.
{% endblockquote %}

There are two inaccuracies in the comment above. First, the problem will happen only if the app is started from the recet apps list, not from the launcher icon. Second, the problem is not limited to `Serializable` extras: `Parcelable` might read the byte stream originally written from a different structure (in this situation crash is a best case scenario), some extras might be missing, some might hold wrong type of data.

Can you prevent this issue? I don't think so, at least not without some sophisticated validation of Intent extras. Considering that this issue is very rare and it goes away after starting the faulty app from somewhere else than recent apps list I don't think you should spend any time trying to fix it, but it's good to know about it, as it might explain some WTF crash reports coming your way.
