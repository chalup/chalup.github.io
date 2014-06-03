---
layout: post
comments: true
title: "The dark side of LINQ: LINQ to SQL on Windows Phone"
date: 2012-04-10T08:23:00+02:00
categories:
 - Windows Phone
 - Rant
 - C#
 - SQL
 - LINQ
 - ORM
---

In case you don't know what's LINQ and you use C#, I suggest you drop everything you do and enlighten yourself. Be warned: when you learn LINQ, you won't be able to work with Java collections (Guava makes them bearable, but barely) or Qt/STL containers without throwing in your mouth every now and then.

Here's tl;dr for the non-enlightened: LINQ is a sane way to query and alter the data. Instead of this:

``` c#
private void PrintSortedEvenNumbers(IList<int> unfiltered)
{
    List<int> filtered = new List<int>();
    foreach (int i in unfiltered)
        if (i % 2 == 0)
            filtered.Add(i);
    filtered.Sort();
    foreach (int i in filtered)
        Console.Write(i + " ");
}
```

You can just write this:

``` c#
private void PrintSortedEvenNumbers(IList<int> unfiltered)
{
    foreach (int i in unfiltered.Where(num => num % 2 == 0).OrderBy(n => n))
        Console.Write(i + " ");
}
```

This is a trivial example, but the more complicated code, the more benefit you get from using LINQ.

I started using it for operations on collections and XML files and I immediately fell in love with it. Imagine my joy when I learned that Windows Phone 7.1 finally supports local relational database which can be queried through LINQ to SQL!

I've read the [tutorial](http://msdn.microsoft.com/en-us/library/hh286405(v=vs.92).aspx), thought a bit about the application I was writing at the time and decided that I need many-to-many relationship. Oops, that's not supported. Well, it's "kinda" supported, meaning you can create a data structure and insert some data, but when you remove the data the foreign key constraints won't be verified and cascade triggers won't work. I think I can simplify the above statement and just call it "not supported feature".

Fortunately I didn't absolutely had to use many-to-many relationship. It would be nicer and would allow us to relax some constraints, but the current data could be as well represented using a nested one-to-many relationships. I've wrote the code based on aforementioned LINQ to SQL tutorial, wrote the tests, run them and watched in amazement as they fail. After googling a lot and experimenting I was able to make my code work, but it was quite different than the crap they posted on MSDN as tutorial. If you want to use LINQ to SQL, take a look at [this code on github](https://gist.github.com/1682648).

I spent about two days reading about LINQ to SQL and experimenting with the code and in the end I didn't even had the data structure I wanted to. And we're not talking here about rocket science, the SQLite scheme I needed was something like this:

``` sql
create table x (id INTEGER PRIMARY KEY AUTOINCREMENT, text STRING);
create table y (id INTEGER PRIMARY KEY AUTOINCREMENT, text STRING);
create table z (id INTEGER PRIMARY KEY AUTOINCREMENT,
                x_id INTEGER NOT NULL,
                y_id INTEGER NOT NULL,
                FOREIGN KEY(x_id) REFERENCES x(id) ON DELETE CASCADE,
                FOREIGN KEY(y_id) REFERENCES y(id) ON DELETE CASCADE);

```

Which leads me to conclusion: LINQ to SQL for Windows Phone just doesn't work. Consider also the amount of boilerplate code I had to write for simple foreign key relation: in case you didn't looked at the github link that's whooping 80 lines of code for every one-to-many relationship. I don't know, maybe there are some tools that generate this stuff for you, but in this case why does the official tutorial even mention writing the table classes by hand? And where are those tools?

Recently I was also playing with Django which also features an ORM for the model definition. You need the foreign key? You use something called `ForeignKey`. You need the many-to-many relationship? You use the `ManyToManyField`. Dirt simple. I'm sure there are some dark corners you have to be aware of, but the basic stuff just works.
