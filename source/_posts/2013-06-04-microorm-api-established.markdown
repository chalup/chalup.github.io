---
layout: post
title: "MicroOrm API established"
date: 2013-06-04T21:51:00+02:00
categories:
 - Android
 - MicroOrm
 - ORM
---

Last weekend I have found some time again to work on the [MicroOrm](https://github.com/chalup/microorm). Basically it's something like google-gson for Android database types - [`Cursors`](http://developer.android.com/reference/android/database/Cursor.html) and [`ContentValues`](http://developer.android.com/reference/android/content/ContentValues.html).

With help from [+Mateusz Herych](http://plus.google.com/108555637824110226040) and [+Bartek Filipowicz](http://plus.google.com/104340031708315230732) I have, hopefully, finalized the API of the v1.0. The [initial draft of the library](/blog/2013/05/28/weekend-hack-microorm-library) supported only basic field types: primitives and their boxed equivalents and of course strings. The current version allows registering adapters for any non-generic types. [+Mateusz Herych](http://plus.google.com/108555637824110226040) added also the `@Embedded` annotation which allows easy nesting of POJOs which are represented by multiple columns.

Those two mechanisms should allow you to write the entity objects for almost any data structure you have.The only unsupported cases are generic entities and generic fields in entities. I decided to leave them out of the first release, because due to type erasure in java the implementation is not straightforward and I don't have such cases anywhere in my code anyways.

The next step is using the library in the existing project. I intend to use it in [Base CRM](http://getbase.com/), which should be sufficiently large project to reveal any [MicroOrm's](https://github.com/chalup/microorm) shortcomings.
