---
layout: post
title: "Android heterogeneous Adapters gotcha"
date: 2012-09-19T23:49:00+02:00
categories:
 - Gotcha
 - Android
---

Unless you were writing your Android apps under some kind of digital rock, you heard about Mark Murphy a.k.a. [commonsguy](https://github.com/commonsguy). Today I'd like to write about a gotcha related to heterogeneous Adapters in general, which recently bit me in the rear when I used (misused?) one of Mark's Android components - [MergeAdapter](https://github.com/commonsguy/cwac-merge).

As you can read on the [project's site](https://github.com/commonsguy/cwac-merge), "MergeAdapter accepts a mix of Adapters and Views and presents them as one contiguous whole to whatever ListView it is poured into". This means of course that this is a heterogeneous adapter, i.e. the one which returns integer > 1 from [`getViewTypeCount()`](http://developer.android.com/reference/android/widget/BaseAdapter.html). The implementation of this method is pretty straightforward - it just iterates through the list of adapters it consists of and returns the sum of `getViewTypeCount()`s :

``` java
@Override
public int getViewTypeCount() {
  int total=0;

  for (PieceState piece : pieces.getRawPieces()) {
    total+=piece.adapter.getViewTypeCount();
  }

  return(Math.max(total, 1)); // needed for
                              // setListAdapter() before
                              // content add'
}
```

Everything is fine and dandy if you use the code like this:

``` java
@Override
public void onCreate(Bundle icicle) {
  super.onCreate(icicle);
  setContentView(R.layout.main);

  MergeAdapter adapter = new MergeAdapter();
  adapter.addView(someView);
  adapter.addAdapter(someAdapter);

  setListAdapter(adapter);
}
```

But sometimes you might want to attach the MergeAdapter to ListView and add fill it later (the real scenario for this case is adding stuff in [`onLoadFinished`](http://developer.android.com/reference/android/support/v4/app/LoaderManager.LoaderCallbacks.html) callback, I'm using contrived example for sake of simplicity):

``` java
@Override
public void onCreate(Bundle icicle) {
  super.onCreate(icicle);
  setContentView(R.layout.main);

  MergeAdapter adapter = new MergeAdapter();
  adapter.addAdapter(someAdapter);

  setListAdapter(adapter);

  adapter.addAdapter(someOtherAdapter);
}
```

This code will work as long as the adapter's contents fit on one screen, but if you start scrolling the list and the item recycling kicks in your app will crash with `ClassCastException` from your adapters' `getView()`. If by some chance you use the same IDs for the Views of the same type the app won't crash, but your items probably won't look exactly as they should. Either way, you won't be happy.

The root cause is the undocumented fact that the getViewTypeCount() is called only once after attaching it with [`ListView.setAdapter()`](http://developer.android.com/reference/android/widget/ListView.html). In the example above, the MergeAdapter contains only one item type when the `setAdapter()` is called, `getViewTypeCount()` will return 1, and adding the second adapter with another item type won't change this.

Why doesn't this crash right away? The ListView will call `getView()` in correct adapters, but then it will try to reuse items created by one adapter for items in the second adapter, because it assumes there is only one view type (`getViewTypeCount()` returned 1).

So what's the lesson here? Do not change the MergeAdapter in loader callbacks, either construct it before `setAdapter()` call (for example add empty [`CursorAdapters`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html) and call [`CursorAdapter.swapCursor()`](http://developer.android.com/reference/android/support/v4/widget/CursorAdapter.html) later) or postpone the `setAdapter()` call until you load all the parts. The more general rule is that you may not calculate the number of item types from the actual data, for example the following code won't work: 

``` java
public class MyCursorAdapter extends CursorAdapter {
  // Implementation of bindView, newView, etc. skipped

  private int mCalculatedItemTypeCount;

  @Override
  public int getViewTypeCount() {
    return Math.max(mCalculatedItemTypeCount, 1);
  }

  @Override
  public void changeCursor(Cursor cursor) {
    mCalculatedItemTypeCount = /* some calculations */;
    super.changeCursor(cursor);
  }
}
```
