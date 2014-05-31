---
layout: post
title: "Clicking unclickable list items"
date: 2014-05-22T22:26:00+02:00
categories:
 - Gotcha
 - Android
---

One of the UI patterns that improve lists usability is dividing items into sections. The section might be the first letter of the main text on the list item, date formatted and rounded in a specific way or whatever makes sense for your data.

From the technical point of view you can either add the header view to every list item and show and hide them as needed or create the separate view for header and regular list item and register multiple view types in your Adapter. Both options were described in details by [+Cyril Mottier](https://plus.google.com/118417777153109946393) in excellent [ListView Tips & Tricks #2: Sectioning Your ListView](http://cyrilmottier.com/2011/07/05/listview-tips-tricks-2-section-your-listview/) blog post.

If you choose the second approach, you'll have to decide what to return from your `Adapter`'s `getItem` and `getItemId` methods for items representing sections. If your sections are not supposed to be clickable, you might implement your `Adapter` like this:
``` java
@Override
public Object getItem(int position) {
  return getItemViewType(position) == TYPE_ITEM
      ? mItems[getCursorPosition(position)]
      : null;
}

@Override
public long getItemId(int position) {
  return getItemViewType(position) == TYPE_ITEM
      ? getCursorPosition(position)
      : 0;
}

@Override
public boolean areAllItemsEnabled() {
  return false;
}

@Override
public boolean isEnabled(int position) {
  return getItemViewType(position) == TYPE_ITEM;
}
```

And your `onListItemClickListener` like this:
``` java
@Override
public void onListItemClick(ListView l, View v, int position, long id) {
  super.onListItemClick(l, v, position, id);

  // dummy action which uses Object returned from getItem(position)
  Log.d("DMFM", getListAdapter().getItem(position).toString());
}
```

If you do so, the Android has a nasty surprise for you:

```
java.lang.NullPointerException
    at org.chalup.dialmformonkey.app.MainFragment.onListItemClick(MainFragment.java:38)
    at android.app.ListFragment$2.onItemClick(ListFragment.java:160)
    at android.widget.AdapterView.performItemClick(AdapterView.java:298)
    at android.widget.AbsListView.performItemClick(AbsListView.java:1100)
    at android.widget.AbsListView$PerformClick.run(AbsListView.java:2749)
    at android.widget.AbsListView$1.run(AbsListView.java:3423)
    at android.os.Handler.handleCallback(Handler.java:725)
    ...
```

The only way this can happen is getting `null` from `Adapter.getItem()`, but this method will be called only for disabled items, right?

``` java
@Override
public void onListItemClick(ListView l, View v, int position, long id) {
  super.onListItemClick(l, v, position, id);

  Log.d("DMFM", "Clicked on item " + position + " which is " +
        (getListAdapter().isEnabled(position) 
            ? "enabled"
            : "disabled")
  );

  // dummy action which uses Object returned from getItem(position)
  Log.d("DMFM", getListAdapter().getItem(position).toString());
}
```

Wrong: 

```
D/DMFM﹕ Clicked on item 4 which is enabled
D/DMFM﹕ Abondance
D/DMFM﹕ Clicked on item 4 which is enabled
D/DMFM﹕ Abondance
D/DMFM﹕ Clicked on item 31 which is enabled
D/DMFM﹕ Aragon
D/DMFM﹕ Clicked on item 31 which is enabled
D/DMFM﹕ Aragon
D/dalvikvm﹕ GC_CONCURRENT freed 138K, 3% free 8825K/9016K, paused 0ms+0ms, total 3ms
D/DMFM﹕ Clicked on item 28 which is disabled
```

It's very difficult to reproduce this error manually, especially if tapping the list item does something more than writing to logcat, but I investigated this issue, because the stack traces above appeared in crash reports on Google Analytics, so several people managed to click exactly wrong area at the wrong time.

I didn't investigate the issue thoroughly, but it seems there must be some disparity between checking the `isEnabled` method and getting the item. If I ever dive into `ListView` code, I'll definitely write about it. If you want to reproduce or investigate the issue yourself, compile [this project](https://github.com/chalup/blog-unclickable-items) and run the monkey:

```
$ adb shell monkey -p org.chalup.dialmformonkey.app -v 500
```

So what can we do? First option is checking the `Adapter.isEnabled()` in your `onListItemClick` listener, which is yet another kind of boilerplate you have to add to your Android code, but it's super easy to add. The other option is going with the first sectioning approach, i.e. putting section as a part of the clickable list item, but it might not work for your use case (for example adapter with multiple item types).
