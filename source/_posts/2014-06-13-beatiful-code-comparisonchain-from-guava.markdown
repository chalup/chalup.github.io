---
layout: post
title: "Beatiful Code: ComparisonChain"
date: 2014-06-13 20:28:24 +0200
comments: true
categories: 
 - Java
 - Guava
---

I usually tend to write about certain [gotchas](/blog/categories/gotcha) and weird [Android issues](/blog/categories/android/), so if you expect yet another rant, I have a surprise for you - today, I'm going to write about a piece of code I'm very fond of.

As you might have noticed, [I'm a big fan of Guava](/blog/categories/guava). One of the classes I extensively use is [`ComparisonChain`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/ComparisonChain.html), which lets you turn this:

``` java
@Override
public int compareTo(Person other) {
  int cmp = lastName.compareTo(other.lastName);
  if (cmp != 0) {
    return cmp;
  }
  cmp = firstName.compareTo(other.firstName);
  if (cmp != 0) {
    return cmp;
  }
  return Integer.compare(zipCode, other.zipCode);
}
```

Into this:

``` java
@Override
public int compareTo(Person other) {
  return ComparisonChain.start()
      .compare(lastName, other.lastName)
      .compare(firstName, other.firstName)
      .compare(zipCode, other.zipCode)
      .result();
}
```

When I first saw this API I was a bit worried about performance, because this code is supposed to be used in `Comparator`s, which are executed multiple times during `Collection` sorting, and it looks like it could allocate a lot of objects. So I looked at the [source code](https://code.google.com/p/guava-libraries/source/browse/guava/src/com/google/common/collect/ComparisonChain.java) and I was enlightened.

ComparisonChain is an abstract class with few versions of `compare` method returning ComparisonChain object:

``` java
  public abstract ComparisonChain compare(Comparable<?> left, Comparable<?> right);
  public abstract <T> ComparisonChain compare(@Nullable T left, @Nullable T right, Comparator<T> comparator);
  public abstract ComparisonChain compare(int left, int right);
  public abstract ComparisonChain compare(long left, long right);
  public abstract ComparisonChain compare(float left, float right);
  public abstract ComparisonChain compare(double left, double right);
  public abstract ComparisonChain compareTrueFirst(boolean left, boolean right);
  public abstract ComparisonChain compareFalseFirst(boolean left, boolean right);

```

To get the result of comparison you call another abstract method:

``` java
  public abstract int result();
```

The trick is, there are only two implementations and three instances of ComparisonChain: anonymous `ACTIVE`, and `LESS` and `GREATER` instances of InactiveComparisonChain.

`ACTIVE` instance is the one you get from `ComparisonChain.start()` call. Various `compare` methods in `ACTIVE` instance perform comparison on supplied arguments, and depending on result return `ACTIVE`, `LESS` or `GREATER` object. Calling `result` on `ACTIVE` ComparisonChain yields 0.

InactiveComparisonChain's instances - `LESS` and `GREATER` - do not perform any comparisons and return themselves - if you got this object, it means that earlier comparison already established the result. The role of this object is just to forward `result` call to appropriate instance. `LESS.result()` returns -1 and `GREATER.result()` +1.

The whole class is elegant, provide beautiful API for a common task and the implementation is very efficient. The world needs more code like this.