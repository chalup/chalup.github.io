---
layout: post
comments: true
title: "Android stuff you probably want to know about"
date: 2013-05-29T23:24:00+02:00
categories:
 - Android
---

About once a month I interview potential employees at [Base CRM](http://getbase.com/). The nice thing about this is that I usually learn a thing or two. The not-so-nice thing about it is that sometimes you have to tell someone that there is much they have to learn.

At this point most of the candidates ask "OK, so what else should I know?". I used to give some ad-hoc answer for this question, but it's not the best idea, because I tend to forget to mention about some stuff; and even if I don't miss anything, the candidate probably won't remember half of what I said because of the stress accompanying the job interview.

Anyways, I decided to write down the list of Android learning materials, blogs, libraries, etc. I recommend reading about.

## Android basics

Some people's Android knowledge can be summed up as "[`Activities`](http://developer.android.com/reference/android/app/Activity.html) + [`AsyncTasks`](http://developer.android.com/reference/android/os/AsyncTask.html)". That's not enough to write anything more complex than Yet Another Twitter Feed app, so if you seriously think of being the Android developer, go to [http://developer.android.com/guide/components/index.html](http://developer.android.com/guide/components/index.html) and fill the gaps in your education.

At the very least you should also know about [`Fragments`](http://developer.android.com/reference/android/app/Fragment.html) and [`Loaders`](http://developer.android.com/reference/android/content/Loader.html). If you want to persist the data, I recommend using the [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html). It looks like a hassle to implement at first, but it solves all the issues with communication between Services and UI. While we're at the [`Services`](http://developer.android.com/reference/android/app/Service.html): you should know the difference between the bound Service and started Service, and you should know that most likely all you need is the [`IntentService`](http://developer.android.com/reference/android/app/IntentService.html). You should also know about [`BroadcastReceivers`](http://developer.android.com/reference/android/content/BroadcastReceiver.html), and what is the ordered broadcast and sticky broadcast. Pay attention on what thread the different components operate.

## Libraries
* [Support library](http://developer.android.com/tools/extras/support-library.html)
* [Guava](https://code.google.com/p/guava-libraries/)
* [ActionBarSherlock](http://actionbarsherlock.com/)
* [JodaTime](http://joda-time.sourceforge.net/)
* [Commons IO](http://commons.apache.org/proper/commons-io/)
* [Dagger](http://square.github.io/dagger/)
* [Otto](http://square.github.io/otto/)
* [Gson](https://code.google.com/p/google-gson/)
* [HoloEverywhere](https://github.com/Prototik/HoloEverywhere)

## Blogs
* [Mark Murphy](http://commonsware.com/blog/)
* [Cyril Mottier](http://cyrilmottier.com/)
* [Romain Guy](http://www.curious-creature.org/category/android/)
* [Roman Nurik](http://roman.nurik.net/)

## Github
* [Jake Wharton](https://github.com/JakeWharton)
* [Square](https://github.com/square)

## Design / UI
* [Android Views](http://www.androidviews.net/)
* [Android UI Patterns blog](http://www.androiduipatterns.com/)
* [Android UI / UX](http://androiduiux.com/)
* [Android Asset Studio](http://android-ui-utils.googlecode.com/hg/asset-studio/dist/index.html)
* [Android cheatsheet for graphic designers](http://petrnohejl.github.io/Android-Cheatsheet-For-Graphic-Designers/)

## Miscellaneous
* [Google I/O app sources](https://code.google.com/p/iosched/)
* [Grepcode](http://grepcode.com/project/repository.grepcode.com/java/ext/com.google.android/android/)
* [AndroidXRef](http://androidxref.com/)

I probably forgot about something very important, so please leave the comment if you thing anything is missing.
