---
layout: post
comments: true
title: "libphonenumber crash on Android 3.2"
date: 2013-03-23T18:54:00+01:00
categories:
 - Gotcha
 - Android
---

Few days ago I saw the most peculiar crash on a tablet with Android 3.2:

```
java.lang.NoSuchFieldError: com.google.i18n.phonenumbers.PhoneNumberUtil$PhoneNumberFormat.RFC3966
```

Of course there is such field in this class, it works on every other Android hardware I have access to. This was a debug build, so it couldn't have been the Proguard issue. The other functionality from the com.google.i18n.phonenumbers package worked fine, the issue only appeared if I wanted to format a phone number using this specific format.

Long story short, it turns out that some old version of libphonenumber, which doesn't support this particular phone number format, is included in the Android build on my 3.2 device. You can verify such thing by calling:

``` java
Class.forName("com.google.i18n.phonenumbers.PhoneNumberUtil");
```

inside a project without any libs - on this single 3.2 device it will return the valid `Class` object, on every other device I tried it throws `ClassNotFoundException`.

I started to wonder if any other libraries are affected, so I picked up some class names from the most popular libraries ([as reported by AppBrain](http://www.appbrain.com/stats/libraries/dev)) and it seems there might be a similar issue with [Apache Commons Codec jar](http://commons.apache.org/codec/). Fortunately there are no issues with stuff like Guava, GSON or support lib.

What's the workaround for this issue? Fork the library and change the package name.
