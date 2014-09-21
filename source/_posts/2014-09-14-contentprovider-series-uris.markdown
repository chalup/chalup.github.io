---
layout: post
title: "ContentProvider series - Uris"
date: 2014-09-14 21:19:18 +0200
comments: true
categories: 
 - Android
 - ContentProvider
---
The `ContentResolver` and `SQLiteDatabase` APIs are very similar:

```
public Cursor query (Uri uri,      String[] projection, String selection, String[] selectionArgs,                                String sortOrder            )
public Cursor query (String table, String[] columns,    String selection, String[] selectionArgs, String groupBy, String having, String orderBy, String limit)
```

Some arguments are renamed, SQL-specific `groupBy`+`having` are omitted, and `limit` also got an axe, but it is pretty much the same, except for the first argument.

Content Uris 101
----------------
Instead of specifying database table, you have to pass the `Uri` describing the resource you want to access. By convention the Uri should have `content` scheme (use [SCHEME_CONTENT](http://developer.android.com/reference/android/content/ContentResolver.html#SCHEME_CONTENT) constant), followed by the `ContentProvider` authority, and the path, which is mapped to resources.

If you have ever accessed any REST-ish API, or built the routes table for the web app, you'll find it familiar. Querying `/foo` should return the list of `foo`s, `/foo/1` operates on `foo` with id `1` and `/foo/1/bar` refers to all `bar`s related to `foo` with id `1`. The last `Uri` pattern is not mentioned in [API Guides](http://developer.android.com/guide/topics/providers/content-provider-creating.html#ContentURI), but is widely used in [Google I/O Schedule app](https://github.com/google/iosched) and system `ContentProvider`s.

Publish - subscribe
-------------------
The `Uri` parameter leaks from `ContentProvider` API into `Cursor`. You can call `Cursor.setNotificationUri()` to specify that the `Cursor` will observe changes on the given `Uri` and propagate the notification to all `ContentObserver`s registered with `Cursor.registerContentObserver()`. So when someone calls `ContentResolver.notifyChange()` on the same Uri, these `ContentObserver`s will be notified of the change. This is the mechanism that powers the automatic reloading of `CursorLoader`s.


But what about the related Uris? Shouldn't observers of `/foo` Uri be notified when the `/foo/1` is updated? In case of standard `Cursors` that's exactly what happens, because the observers registered in `AbstractCursor` base class use `true` as `notifyForDescendents` parameter. But if your specific use case requires observing only single specific Uri, you can call `contentResolver.registerContentObserver(uri, false, observer)`.

Semantics
---------
Content Uri semantics for querying content, i.e. how the Uri path affects the query, were already described in "Content Uris 101" section above. Semantics for other actions are not explicitly specified anywhere in the Android documentation, but again I/O Schedule app and system `ContentPovider`s implement it in a common way that can be thought of as standard to be followed.

For deletes and updates the Uri path are treated the same ways as for queries - as additional selection.

For inserts, the Uri path is translated to additional `ContentValues` that should be inserted into database, e.g. insert on `/foo/42/bar` create new `bar` record with supplied `ContentValues` and with `foo_id` (or similar foreign key field) set to 42.

Issue #1 - many to many
-----------------------
The described mechanics work well for one-to-many relations, but there is a problem with entities in many-to-many relations. Let's use `sessions` and `tags` from Google I/O Schedule app as an example. Each session can be tagged with mutliple tags, and many sessions can be tagged with the same tag.

The semantics of querying `/sessions/*/tags` or `/tags/*/sessions` are OK. The first one should return all tags of a given session and the second one should yield the list of sessions tagged with a given tag. But on which Uri should you insert a new link between existing tag and existing session?

Usually many-to-many relationships are modeled with linking table, in this case "sessions_tags". But you cannot really pass the related tag and session in Uri path: `/sessions/*/tags/*/sessions_tags` or similar Uris look weird. One option is to put it directly in ContentValues, but this means that this entities will be created in a different way than all the other entities in one-to-many relations. Another option is use query parameters, i.e. insert on `/sessions_tags?relatedTo=/tags/*&relatedTo=/sessions/*` Uri, which is ugly, but explicit.

Issue #2 - subscription vs. joins
---------------------------------
Let's go back to querying the `/sessions/*/tags` endpoint. Under the hood we'd join `tags` table with `sessions_tags` table, but most likely we'd set the `Cursor`'s notification Uri to `/sessions/*/tags`. It means that our Cursor won't be notified of changes on `/tags`, `/sessions_tags` and descendant Uris, although it might affect the data we queried.

The only solution offered by Android SDK is calling `notifyChange` on insert, delete and update with multiple Uris, but there are two issues with this approach: you might end up notifying half of your endpoints for every small change, forcing way to many content reloads; it's error prone, because changing one endpoint might require manual changes of many different endpoints.

What you really need for such cases are multiple notification Uris on Cursor, alas, that's not possible with regular Cursors implementations.