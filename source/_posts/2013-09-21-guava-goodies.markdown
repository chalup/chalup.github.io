---
layout: post
comments: true
title: "Guava goodies"
date: 2013-09-21T14:49:00+02:00
categories:
 - Java
 - Guava
 - Android
---

This is a long overdue post after my [Guava on Android](/blog/2013/02/20/guava-on-android) post from February. Since then I've been using [Guava](https://code.google.com/p/guava-libraries/) in pretty much every Java project I was involved in and I still find new stuff that makes my code both shorter and clearer. Some random examples:

[`Objects.equal()`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Objects.html#equal%28java.lang.Object, java.lang.Object%29)
``` java
// instead of:
boolean equal = one == null
    ? other == null
    : one.equals(other);

// Guava style:
boolean equal = Objects.equal(one, other);
```

[`Objects.hashcode()`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Objects.html#hashCode%28java.lang.Object...%29)
``` java
// instead of:
@Override
public int hashCode() {
  int result = x;
  result = 31 * result + (y != null ? Arrays.hashCode(y) : 0);
  result = 31 * result + (z != null ? z.hashCode() : 0);
  return result;
}

// Guava style:
@Override
public int hashCode() {
  return Objects.hashCode(x, y, z);
}
```

[`Joiner`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/base/Joiner.html)
``` java
// instead of:
StringBuilder b = new StringBuilder();
for (int i = 0; i != a.length; ++i) {
  b.append(a[i]);
  if (i != a.length - 1) {
    b.append(", ");
  }
}
return b.toString();

// Guava style:
Joiner.on(", ").join(a);
```

[`ComparisonChain`](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/ComparisonChain.html)
``` java
// instead of:
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

// Guava style:
@Override
public int compareTo(Person other) {
  return ComparisonChain.start()
      .compare(lastName, other.lastName)
      .compare(firstName, other.firstName)
      .compare(zipCode, other.zipCode)
      .result();
}
```

Lists, Maps and Sets classes contain bunch of newFooCollection, which effectively replace the diamond operator from JDK7, but also allow you to initialize the collection from varargs.

Sets also contain the difference, intersection, etc. methods for common operations on sets, which a) have sane names, unlike some stuff from JDK's Collections, and b) doesn't change operands, so you don't have to make a defensive copy if you want to use the same set in two operations.

Speaking of defensive copying: Guava has a set of [Immutable collections](https://code.google.com/p/guava-libraries/wiki/ImmutableCollectionsExplained), which were created just for this purpose. There are few other very useful collections: [`LoadingCache`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/cache/LoadingCache.html), which you can think of as a lazy map with specified generator for new items; [`Multiset`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/Multiset.html), very handy if you need to build something like a histogram; [`Table`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/Table.html) if you need to lookup value using two keys.

The other stuff I use very often are [`Preconditions`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/base/Preconditions.html). It's just a syntactic sugar for some sanity checks in your code, but it makes them more obvious, especially when you skim through some unfamiliar code. Bonus points: if you don't use the return values from `checkNotNull` and `checkPositionIndex`, you can remove those checks from performance critical sections using Proguard.

On Android you have the [`Log.getStackTraceString()`](http://developer.android.com/reference/android/util/Log.html#getStackTraceString%28java.lang.Throwable%29) helper method, but in plain Java you'd have to build one from [`Throwable.getStackTrace()`](http://developer.android.com/reference/java/lang/Throwable.html#getStackTrace%28%29). Only you don't have to do this, since Guava have [`Throwables.getStackTraceAsString()`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/base/Throwables.html#getStackTraceAsString%28java.lang.Throwable%29) utility method.

Guava introduces also some functional idioms in form of [`Collections2.transform`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/Collections2.html#transform%28java.util.Collection, com.google.common.base.Function%29) and [`Collections2.filter`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/Collections2.html#filter%28java.util.Collection, com.google.common.base.Predicate%29), but I have mixed feelings about them. On one hand sometimes they are life savers, but usually they make the code much uglier than the good ol' imperative for loop, so ues them with caution. They get especially ugly when you need to chain multiple transformations and filters, but for this case the Guava provides the [`FluentIterable`](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/FluentIterable.html) interface.

None of the APIs listed above is absolutely necessary, but seriously, you want to use Guava ([but sometimes not the latest version](/blog/2013/06/26/guava-and-minsdkversion)). Each part of it raises the abstraction level of your code a tiny bit, improving it one line at the time.
