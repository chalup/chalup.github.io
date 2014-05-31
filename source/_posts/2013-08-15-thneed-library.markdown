---
layout: post
title: "Thneed library"
date: 2013-08-15T23:32:00+02:00
categories:
 - Thneed
 - Android
 - MicroOrm
 - ORM
---

The [MicroOrm](https://github.com/chalup/microorm) library I started [a while ago](/blog/2013/05/28/weekend-hack-microorm-library) solves only a tiny part of data model related problems - conversion between strongly typed objects and storage classes specific for Android. We discussed few existing libraries for data model implementation we might use at [Base CRM](http://getbase.com/), but we were not fully satisfied with any of them. There are two approaches to this problem:

The first approach is to define the Data Access Objects / entity objects and create SQLite tables using this data. Almost every ORM solution for Android works this way. The deal breaker for those solutions is the complete disregard for data migrations. The [ORMLite docs](http://ormlite.com/javadoc/ormlite-core/doc-files/ormlite_4.html#Upgrading-Schema) suggest that you should just fall back to the raw queries, but this means that you need to know the schema generated from DAOs, which is a classic case of [leaky abstraction](http://www.joelonsoftware.com/articles/LeakyAbstractions.html).

The completely opposite approach is used in [Mechanoid library](http://robotoworks.com/mechanoid/doc/db/). You define the database schema as a sequence of migrations and the library generates the DAOs and some other stuff. I was initially very excited about this project, but it's in a very early state of development and the commit activity is not very high. The main problem with this concept is extensibility and customization. For both you probably have to change the way the code is generated from parsed SQLite schema. We also have some project specific issues that would makes this project hard to use.

At the end we haven't found an acceptable solution among existing libraries and frameworks, but something good came out of our discussions. The sentence which came up again and again was "It wouldn't be too hard to implement if we knew the relationships between our models". Wait a minute, we do know these relationships! We just need a way to represent them in the Java code!

And so, the [Thneed](https://github.com/chalup/thneed) was born.

By itself the Thneed doesn't do anything useful - it just lets you tell that one X has many Ys and so on, to create a relationship graph of your data models. The trick is, this graph is a Visitable part of [Visitor design pattern](http://en.wikipedia.org/wiki/Visitor_pattern), which means that you can write any number of Visitors to do something useful with the information about declared relationships (see the [project's readme](https://github.com/chalup/thneed/blob/master/README.md) for some ideas). Think about it as a tool for creating other tools.

The project is in a very early stage, but I've already started [another project](https://github.com/futuresimple/forger) on top of Thneed and at this point the general idea seems sound. I've also learned few tricks I'll write about in a little while. As usual, the feedback is welcome, and if you find this idea interesting, do not hesitate to [star](https://github.com/chalup/thneed/star) the project [on Github](https://github.com/chalup/thneed/).
