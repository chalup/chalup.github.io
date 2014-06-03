---
layout: post
comments: true
title: "Forger library"
date: 2013-09-12T23:19:00+02:00
categories:
 - Thneed
 - Java
 - Forger
 - Android
 - MicroOrm
 - visitor
---

Sometimes the code you write is hard to test, and the most likely reason for this is that you wrote a shitty code. Other times, the code is quite easy to test, but setting up the test fixture is extremely tedious. It may also mean that you wrote a shitty code, but it may also mean that you don't have the right tools.

For me the most painful part of writing tests was filling the data model with some fake data. The most straightforward thing to do is to write helper methods for creating this data, but this means you'll have two pieces of code to maintain side by side: the data model and the helper methods. The problem gets even more complicated when you need to create a whole hierarchy of objects.

The first step is generating a valid [`ContentValues`](http://developer.android.com/reference/android/content/ContentValues.html) for your data model. You need to know the column names and the type of the data that should be generated for a given column. Note that for column data type you cannot really use the database table definitions - for example sqlite doesn't have boolean column type, so you'd define your column as integer, but the valid values for this column are only 1 and 0.

This is not enough though, because you'd generate random values for the foreign keys, which might crash the app (if you enforce the foreign key constraints) or break some other invariants in your code. You might work around this by creating the objects in the right order and overriding generated data for foreign key columns, but this would be tedious and error prone solution.

I have recently posted about my two side-projects: [MicroOrm](https://github.com/chalup/microorm) and [Thneed](https://github.com/chalup/thneed). The former let's you annotate fields in POJO and handles the conversion from POJO to ContentValues and from Cursor to POJO:

``` java
public class Customer {
  @Column("id")
  public long id;

  @Column("name")
  public String name;
}

public class Order {
  @Column("id")
  public long id;

  @Column("amount")
  public int amount;

  @Column("customer_id")
  public long customerId;
}
```

The latter allows you to define the relationships between entities in your data model:

``` java
ModelGraph<ModelInterface> modelGraph = ModelGraph.of(ModelInterface.class)
    .identifiedByDefault().by("id")
    .where()
    .the(ORDER).references(CUSTOMER).by("customer_id")
    .build();
```

See what I'm getting at?

The returned ModelGraph object is a data structure that can be processed by independently written processors, i.e. they are the Visitable and Visitor parts of the [visitor design pattern](http://en.wikipedia.org/wiki/Visitor_pattern). The entities in relationship definitions are not a plain marker Objects - the first builder call specifies the interface they have to implement. This interface can be used by Visitors to get useful information about the connected models and, as a type parameter of ModelGraph, ensures that you are using the correct Visitors for your ModelGraph. See [my last post about Visitors](/blog/2013/08/25/random-musings-on-visitor-design) for more information about generifying the visitor pattern.

In our case the interface should declare which POJO contains [MicroOrm](https://github.com/chalup/microorm) annotations and where should the generated [`ContentValues`](http://developer.android.com/reference/android/content/ContentValues.html) be inserted:

``` java
public interface MicroOrmModel {
  public Class<?> getModelClass();
}

public interface ContentResolverModel {
  public Uri getUri();
}

interface ModelInterface extends ContentResolverModel, MicroOrmModel {
}

public static final ModelInterface CUSTOMER = new ModelInterface() {
  @Override
  public Uri getUri() {
    return Customers.CONTENT_URI;
  }

  @Override
  public Class<?> getModelClass() {
    return Customer.class;
  }
}
```

The final step is to wrap everything in fluent API: 

``` java
Forger<ModelInterface> forger = new Forger(modelGraph, new MicroOrm());
Order order = forger.iNeed(Order.class).in(contentResolver);

// note: we didn't created the Customer dependency of Order, but:
assertThat(order.customer_id).isNotEqualTo(0);

// of course we can create Customer first and then create Order for it:
Customer customer = forger.iNeed(Customer.class).in(contentResolver);
Order anotherOrder = forger.iNeed(Order.class).relatedTo(customer).in(contentResolver);

assertThat(anotherOrder.customer_id).isEqualTo(customer.id);

// or if we need multiple orders for the same customer:
Customer anotherCustomer = forger.iNeed(Customer.class).in(contentResolver);
Forger<ModelInterface> forgerWithContext = forger.inContextOf(anotherCustomer);

Order orderA = forgerWithContext.iNeed(Order.class).in(contentResolver);
Order orderB = forgerWithContext.iNeed(Order.class).in(contentResolver);

assertThat(orderA.customer_id).isEqualTo(anotherCustomer.id);
assertThat(orderB.customer_id).isEqualTo(anotherCustomer.id);
```

The most pathological case in our code base was a test with 10 lines of code calling over 100 lines of helper methods and 6 lines of the actual test logic. The [Forger](https://github.com/futuresimple/forger) library allowed us to get rid of all the helper methods and reduce the 10 lines of setup to 1 fluent API call (it's quite a long call split into few lines, but it's much prettier than the original code).

Check out the [code on github](https://github.com/futuresimple/forger) and don't [forget to star](https://github.com/futuresimple/forger/star) this project if you find it interesting.

The funny thing about this project is that it's a byproduct of [Thneed](https://github.com/chalup/thneed), which I originally wrote to solve another problem. It makes me think that the whole idea of defining the relationships as a visitable structure is more flexible than I originally anticipated and it might become the cornerstone of the whole set of useful tools.
