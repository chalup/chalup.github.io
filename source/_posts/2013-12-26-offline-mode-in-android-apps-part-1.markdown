---
layout: post
title: "Offline mode in Android apps, part 1 - data migrations"
date: 2013-12-26T14:05:00+01:00
categories:
 - offline mode
 - Android
 - db
---

This year I gave a talk on [Krakdroid](http://www.krakdroid.pl/) conference about offline mode in Android apps. By offline mode I mean implementing the app such way that the network availability is completely transparent to the end users. The high level implementation idea is to decouple the operations changing the data from sending these changes through unreliable network by saving the changes in local database and sending them at convinient moment. We have encountered two major problems when we implemented this behavior in [Base CRM](https://play.google.com/store/apps/details?id=com.futuresimple.base): data migrations and identifying entities. This blog post describes the first issue.
It might not be obvious why do you need the data migrations, so let's clear this out. Let's say on your mobile you have some data synced with backend (green squares on left and right) and some unsynced data created locally on mobile (red squares on the left).

{% img center /images/unsynced.png %}

Now let's say that we introduce new functionality to our app, which changes the schema of our data models (the squares on the backend side are changed to circles).

{% img center /images/schemachange.png %}

The schema of the local database have to be changed as well. The naive way of handling this situation is dropping old database with old schema, creating new one with new schema and resyncing all the data from backend, but there are two issues with this approach: if there is a lot of data the resyncing might take a while, which negates the most important advantage of offline mode - that the app is fully functional all the time.

{% img center /images/lotofdata.png %}

More serious issue is that dropping the old database means that the unsynced data will be dropped along with it.

{% img center /images/unsynceddata.png %}

The only way to provide the optimal user experience is to perform schema migrations locally for both synced and unsynced data:

{% img center /images/migration.png %}

Migrating the data doesn't sound like a challenging thing to code, but the combination of obscure SQLite and Android issues complicates the matter. Without proper tools it's quite easy to make your code unmaintainable in the long run. I'll describe this issues and our solutions in the further posts.
