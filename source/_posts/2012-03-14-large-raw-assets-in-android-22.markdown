---
layout: post
comments: true
title: "Large raw assets in Android 2.2"
date: 2012-03-14T07:50:00+01:00
categories:
 - Gotcha
 - Android
---

My most recent application, [Word Judge](https://play.google.com/store/apps/details?id=com.chalup.WordJudgeEN), contains full dictionary of word valid in word games. I went to great lengths to minimize the size of this data, but for some languages it's still quite large. For example polish dictionary is compressed from 35MB to 1.4MB. In Android 2.2 and earlier, if you add such large file as an asset and then try to open it, you'll get `IOException`. The exception itself doesn't contain any useful information, but the following text appears in logcat:

```
03-07 14:40:42.345: D/asset(301): Data exceeds UNCOMPRESS_DATA_MAX (1442144 vs 1048576)
```

With that information [googling the workaround is easy](http://www.google.pl/search?sourceid=chrome&ie=UTF-8&q=UNCOMPRESS_DATA_MAX+site%3Astackoverflow.com). Some folks recommend splitting the file into multiple parts, or repackaging the apk, but the simplest solution is to change the file extension of your asset to one of the extensions listed in aapt tool sources as files that are not compressed by default:

``` java
/* these formats are already compressed, or don't compress well */
static const char* kNoCompressExt[] = {
    ".jpg", ".jpeg", ".png", ".gif",
    ".wav", ".mp2", ".mp3", ".ogg", ".aac",
    ".mpg", ".mpeg", ".mid", ".midi", ".smf", ".jet",
    ".rtttl", ".imy", ".xmf", ".mp4", ".m4a",
    ".m4v", ".3gp", ".3gpp", ".3g2", ".3gpp2",
    ".amr", ".awb", ".wma", ".wmv"
};
```

Of course if you target API level 9 or newer, you don't have to worry about this gotcha.

There is one more thing worth mentioning: the speed of IO operations in debug mode is atrocious. Loading the 1.4MB dictionary to memory takes over 10 seconds. Fortunately when the program is running without debugger attached, the loading time decreases to less than 1 second.
