---
layout: post
comments: true
title: "Random musings on Visitor design pattern in Java"
date: 2013-08-25T13:21:00+02:00
categories:
 - Thneed
 - Java
 - covariance and contravariance
 - generics
 - design patterns
 - visitor
---

First let's have a quick refresher on what is the [visitor design pattern](http://en.wikipedia.org/wiki/Visitor_pattern). This pattern consists of two elements: the Visitor, which in the Gang of Four book is defined as an "operation to be performed on the elements of an object structure"; the second element is the structure itself.

``` java
public interface Visitable {
  void accept(Visitor visitor);
}

public interface Visitor {
}
```

The Visitor interface is for now empty, because we haven't declared any Visitable types. In every class implementing Visitable interface we'll call a different method in Visitor:

``` java
public interface Visitable {
  void accept(Visitor visitor);
}

public static class VisitableFoo implements Visitable {
  @Override
  public void accept(Visitor visitor) {
    visitor.visit(this);
  }
}

public static class VisitableBar implements Visitable {
  @Override
  public void accept(Visitor visitor) {
    visitor.visit(this);
  }
}

public interface Visitor {
  void visit(VisitableBar visitableBar);
  void visit(VisitableFoo visitableFoo);
}
```

Sounds like a lot of work, but there is a reason for it. You could achieve something similar by simply adding another method to the Visitable pattern, but this means you'd have to be able to modify the Visitable classes. The visit/accept double dispatch allows you to write a library like [Thneed](https://github.com/chalup/thneed), which defines the data structure, but leaves the operations implementation to the library users.

The classic visitor pattern requires you to keep some kind of state and to write a method for getting and clearing this state. This might be what you want, but if you want to simply process your Visitable objects one by one and return independent computations, you might want just to return a value from visit() method. So the first twist you can add to classic Visitor pattern is to return a value from visit/accept method:

``` java
public interface Visitable {
  <TReturn> TReturn accept(Visitor<TReturn> visitor);
}

public static class VisitableFoo implements Visitable {
  @Override
  public <TReturn> TReturn accept(Visitor<TReturn> visitor) {
    return visitor.visit(this);
  }
}

public static class VisitableBar implements Visitable {
  @Override
  public <TReturn> TReturn accept(Visitor<TReturn> visitor) {
    return visitor.visit(this);
  }
}

public interface Visitor<TReturn> {
  TReturn visit(VisitableBar visitableBar);
  TReturn visit(VisitableFoo visitableFoo);
}
```

Note that only Visitor interface is parametrized with a return type. The only thing that `Visitable.accept()` do is dispatching the call to Visitor, so there is no point in generifying the whole interface, it's sufficient to make an accept method generic. In fact, making the TReturn type a Visitable interface type would be a design mistake, because you wouldn't be able to create a Visitable that could be accepted by Visitors with different return types:

``` java
public interface Visitable<TReturn> {<br/>  TReturn accept(Visitor<TReturn> visitor);<br/>}
```

Because of type erasure you wouldn't be able to create a Visitable that can accept two Visitors returning a different types:

``` java
public static class MyVisitable implements Visitable<String>, Visitable<Integer> {
  // Invalid! "Duplicate class Visitable" compilation error.
}
```

Another thing you can do is generifying the whole pattern. The use case for this is when your Visitables are some kind of containers or wrappers over objects (again, see the [Thneed](https://github.com/chalup/thneed) library, where the Visitables subclasses are the different kinds of relationships between data models and are parametrized with the type representing the data models). The naive way to do this is just adding the type parameters:

``` java
public interface Visitable<T> {
  void accept(Visitor<T> visitor);
}

public static class VisitableFoo<T> implements Visitable<T> {
  @Override
  public void accept(Visitor<T> visitor) {
    visitor.visit(this);
  }
}

public static class VisitableBar<T> implements Visitable<T> {
  @Override
  public void accept(Visitor<T> visitor) {
    visitor.visit(this);
  }
}

public interface Visitor<T> {
  void visit(VisitableBar<T> visitableBar);
  void visit(VisitableFoo<T> visitableFoo);
}
```

There is a problem with the signatures of those interfaces. Let's say that we want our Visitor to operate on Visitables containing Numbers:

``` java
Visitor<Number> visitor = new Visitor<Number>() {
  @Override
  public void visit(VisitableBar<Number> visitableBar) {
  }

  @Override
  public void visit(VisitableFoo<Number> visitableFoo) {
  }
};
```

You should think about Visitor as the method accepting the Visitable. If our Visitor can handle something that contains Number, it should also handle something that contain any Number subclass - it's a classic example of ["consumer extends, producer super"](https://sites.google.com/site/io/effective-java-reloaded) behaviour or [covariance and contravariance](http://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)) in general. In the implementation above however, the strict generics types are causing compilation errors. [Generics wildcards](http://docs.oracle.com/javase/tutorial/extra/generics/wildcards.html) to the rescue:

``` java
public interface Visitable<T> {
  void accept(Visitor<? super T> visitor);
}

public static class VisitableFoo<T> implements Visitable<T> {
  @Override
  public void accept(Visitor<? super T> visitor) {
    visitor.visit(this);
  }
}

public static class VisitableBar<T> implements Visitable<T> {
  @Override
  public void accept(Visitor<? super T> visitor) {
    visitor.visit(this);
  }
}

public interface Visitor<T> {
  void visit(VisitableBar<? extends T> visitableBar);
  void visit(VisitableFoo<? extends T> visitableFoo);
}
```

Note that the change has to be symmetric, i.e. both the `accept()` and `visit()` signatures have to include the bounds. Now we can safely call: 

``` java
VisitableBar<Integer> visitableBar = new VisitableBar<Integer>();
Visitor<Number> visitor = new Visitor<Number>() {
  // visit() implementations
}

visitableBar.accept(visitor);
```
