---
layout: post
title: "Thneed, notes and db design"
date: 2013-11-03T18:59:00+01:00
categories:
 - Thneed
 - SQL
 - db
---

We're starting to find more and more interesting use cases for [Thneed](https://github.com/chalup/thneed) in Base CRM codebase. The first release using it, and [few](https://github.com/chalup/microorm) [other](https://github.com/futuresimple/forger) [libraries](https://github.com/futuresimple/android-db-commons) [we](https://github.com/futuresimple/android-autoindexer) [recently](https://github.com/futuresimple/android-schema-utils) [developed](https://github.com/futuresimple/sqlitemaster), was released just before the Halloween and we haven't registered any critical issues related to it. All in all, the results look very promising. I won't recommend using [Thneed](https://github.com/chalup/thneed) in your production builds yet, but I urge you to [star the project on Github](https://github.com/chalup/thneed/star) and watch its progress.

The [Thneed](https://github.com/chalup/thneed) was created as an answer to some issues we faced when developing and maintaining [Base CRM](https://getbase.com/), and this fact is sometimes reflected by the API. The example of this is something we internally called PolyModels.

Let's start with a scenario, where we have a some objects and we'd like to add notes to. It's a classic one-to-many relationship, which I'd model with a foreign key in notes table:

``` sql
CREATE TABLE some_entity (id INTEGER);
CREATE TABLE notes (
    id INTEGER, 
    some_entity_id INTEGER REFERENCES some_entity(id), 
    content TEXT
);
```

Now let's introduce another type of objects, which also can have notes attached to it. We have few options now. The simplest thing to do is to keep these notes in a completely separate table:

``` sql
CREATE TABLE other_entity (id INTEGER);
CREATE TABLE other_enity_notes (
    id INTEGER, 
    other_entity_id INTEGER REFERENCES other_entity(id), 
    content TEXT
);
```

The issue with this solution is that we have two separate schemas that need to be updated in parallel, and in 95% of cases would be exactly the same. Another approach is making the objects which contain notes sort of inherit a base class:

``` sql
CREATE TABLE notables (id INTEGER);
CREATE TABLE some_entity (id INTEGER, notable_id INTEGER REFERENCES notables(id));
CREATE TABLE other_entity (id INTEGER, notable_id INTEGER REFERENCES notables(id));
CREATE TABLE notes (
    id INTEGER, 
    notable_id INTEGER REFERENCES notables(id), 
    content TEXT
);
```

These two solutions work perfectly in the "give me all notes for object X" scenario, but it gets ugly if you want to display a single note with the simple "Associated with object X" info. In this case you have to query every model which can contain notes, to see if this particular association references the objects from this model. On top of that, the Noteable table approach requires some additional work to create the entry in

You can always have a several mutually exclusive foreing keys in your notes:

``` sql
CREATE TABLE some_entity (id INTEGER);
CREATE TABLE other_entity (id INTEGER);
CREATE TABLE notes (
    id INTEGER, 
    some_entity_id INTEGER REFERENCES some_entity(id), 
    other_entity_id INTEGER REFERENCES other_entity(id), 
    content TEXT
);
```

But this solution doesn't really scale well as the number of the models which can contain notes increases. Also, your DBAs will love you if you go this way.

The solution to this problem we used in Base was to have two columns in Notes table: one holding the type of the "noteable" object, i.e. and the other for the id of this object:

``` sql
CREATE TABLE some_entity (id INTEGER);
CREATE TABLE other_entity (id INTEGER);
CREATE TABLE notes (
    id INTEGER, 
    noteable_id INTEGER, 
    noteable_type TEXT, 
    content TEXT
);
```

The glaring issue with this approach is losing the consistency guarantee - no database I know of support this kind of foreign keys. But when you have SOA on the backend and the notes are stored in a separate database than the noteable objects, this is not your top concern. On mobile apps, even though we have a single database, we use the same structure, because all the other have some implementation issues and worse performance characteristics.

I'm not a db expert, and I haven't found any discussion of similar cases, which means that a) we're doing something very wrong or b) we have just very specific requirements. Let me know if it's a former case.

I needed to model this relationships in Thneed, which tured out to be quite tricky, but that's the topic for another blog post.
