---
layout: post
comments: true
title: "More Guava goodies - AbstractIterator"
date: 2013-10-04T23:19:00+02:00
categories:
 - Java
 - Guava
 - Android
---

A while ago I wanted to perform a certain operation for every subsequent pair of elements in collection, i.e. for list `[1, 2, 3, 4, 5]` I wanted to do something with pairs `[(1, 2), (2, 3), (3, 4), (4, 5)]`. In Haskell that would be easy:

``` haskell
Prelude> let frobnicate list = zip (init list) (tail list)
Prelude> frobnicate [1..5]
[(1,2),(2,3),(3,4),(4,5)]
```

The problem is, I needed this stuff in my Android app, which means Java. The easiest thing to write would be obviously:

``` java
List<T> list;
for (int i = 1; i != list.size(); ++i) {
  T left = list.get(i-1);
  T right = list.get(i);

  // do something useful
}
```

But where's the fun with that? Fortunately, there is Guava. It doesn't have the `zip` or `init` functions, but it provides tool to write them yourself - the [`AbstractIterator`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/AbstractIterator.html). **Tl;dr** of the documentation: override one method returning an element or returning special marker from `endOfData()` method result.

The zip implementation is pretty straightforward:

``` java
public static <TLeft, TRight> Iterable<Pair<TLeft, TRight>> zip(final Iterable<TLeft> left, final Iterable<TRight> right) {
  return new Iterable<Pair<TLeft, TRight>>() {
    @Override
    public Iterator<Pair<TLeft, TRight>> iterator() {
      final Iterator<TLeft> leftIterator = left.iterator();
      final Iterator<TRight> rightIterator = right.iterator();

      return new AbstractIterator<Pair<TLeft, TRight>>() {
        @Override
        protected Pair<TLeft, TRight> computeNext() {
          if (leftIterator.hasNext() && rightIterator.hasNext()) {
            return Pair.create(leftIterator.next(), rightIterator.next());
          } else {
            return endOfData();
          }
        }
      };
    }
  };
}
```

The tail can be achieved simply by calling the `Iterables.skip`:

``` java
public static <T> Iterable<T> getTail(Iterable<T> iterable) {
  Preconditions.checkArgument(iterable.iterator().hasNext(), "Iterable cannot be empty");
  return Iterables.skip(iterable, 1);
}
```

For init you could write similar function:

``` java
public static <T> Iterable<T> getInit(final Iterable<T> iterable) {
  Preconditions.checkArgument(iterable.iterator().hasNext(), "Iterable cannot be empty");
  return Iterables.limit(iterable, Iterables.size(iterable));
}
```

But this will iterate through the entire iterable to count the size. We don't need the count however, we just need to know if there is another element in the iterable. Here is more efficient solution:

``` java
public static <T> Iterable<T> getInit(final Iterable<T> iterable) {
  Preconditions.checkArgument(iterable.iterator().hasNext(), "Iterable cannot be empty");

  return new Iterable<T>() {
    @Override
    public Iterator<T> iterator() {
      final Iterator<T> iterator = iterable.iterator();
      return new AbstractIterator<T>() {
        @Override
        protected T computeNext() {
          if (iterator.hasNext()) {
            T t = iterator.next();
            if (iterator.hasNext()) {
              return t;
            }
          }
          return endOfData();
        }
      };
    }
  };
}
```

All methods used together look like this:

``` java
List<T> list;
for (Pair<T, T> zipped : zip(getInit(list), getTail(list))) {
  // do something useful
}
```
