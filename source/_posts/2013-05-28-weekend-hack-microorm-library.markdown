---
layout: post
comments: true
title: "Weekend hack: MicroOrm library"
date: 2013-05-28T17:28:00+02:00
categories:
 - Android
 - MicroOrm
 - ORM
---

Last week I had to write some `fromCursor()` and `getContentValues()` boilerplate. Again. I finally got fed up and decided to write a library to replace all the hand rolled crap.

You may ask, why not use some existing ORM solution? There are plenty, five minutes with Google yielded these results:

* [http://www.mobeelizer.com/](http://www.mobeelizer.com/)
* [http://ormlite.com/](http://ormlite.com/)
* [http://greendao-orm.com/](http://greendao-orm.com/)
* [https://github.com/ahmetalpbalkan/orman](https://github.com/ahmetalpbalkan/orman)
* [http://hadi.sourceforge.net/](http://hadi.sourceforge.net/)
* [https://www.activeandroid.com/](https://www.activeandroid.com/)
* [https://github.com/roscopeco/ormdroid](https://github.com/roscopeco/ormdroid)
* [http://droidparts.org/](http://droidparts.org/)
* [http://robotoworks.com/mechanoid-plugin/](http://robotoworks.com/mechanoid-plugin/)

The problem is, all those solutions are all-or-nothing, full blown ORMs, and all I need is the sane way to convert the [`Cursor`](http://developer.android.com/reference/android/database/Cursor.html) to POJO and POJO to [`ContentValues`](http://developer.android.com/reference/android/content/ContentValues.html).

And thus, the [MicroOrm](https://github.com/chalup/microorm) project was born. The public API was inspired by [google-gson](https://code.google.com/p/google-gson/) project and is dead simple:

``` java
public class MicroOrm {
  public <T> T fromCursor(Cursor c, Class<T> klass);
  public <T> T fromCursor(Cursor c, T object);
  public <T> ContentValues toContentValues(T object);
  public <T> Collection<T> collectionFromCursor(Cursor c, Class<T> klass);
}
```

I'd like to keep this library as simple as possible, so this is more or less the final API. I intend to add the `MircroOrm.Builder` which would allow registering adapters for custom types, but I haven't decided yet to what extent the conversion process should be customisable.

The elephant in the room is obviously the performance. Current implementation is reflection-based, which incurs the significant overhead. I did some quick benchmarking and it seems that the MicroOrm is about 250% slower than the typical boilerplate code. Sounds appaling, but it's not that bad if you consider that a) the elapsed time of a single fromCursor call is still measured in 100s of microseconds and b) if you really need to process a lot of data you can fall back to manual `Cursor` iteration. I'm also considering changing the implementation to use code generation instead of reflection, similarly to Jake Wharton's butterknife, which should solve the performance problems.

In the following weeks I'll try to adapt the [Base CRM](https://play.google.com/store/apps/details?id=com.futuresimple.base) code I'm working on to use the MicroOrm, and I expect this project to evolve as I face the real-life issues and requirements. All feedback, comments, ideas and pull requests are more than welcome. You can also show the support by [starring](https://github.com/chalup/microorm/star) the project on [Github](https://github.com/chalup/microorm).
