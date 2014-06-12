---
layout: post
title: "Android Loaders"
date: 2014-06-12 22:47:43 +0200
comments: true
categories:
 - Android
 - Loaders
---

If you fetch the data from any `ContentProvider` in your application, the most likely scenarios are:

1. You're absolutely clueless and fetch the data on UI thread.
2. You're using an `AsyncTask` and:
	* Your app crashes on screen orientation change.
	* You block the screen orientation, because you googled this "solution" on StackOverflow.
	* You wrote error prone boilerplate code to detach and reattach the `AsyncTask` from the Activity.
3. You are using `CursorLoader`.

But accessing `ContentProvider` is probably not the only type of asynchronous operations you perform. You might want to access `SharedPreferences`, read a file or query a web API. In that case you need `Loader<SomeOtherDataThanCursor>`, but implementing one correctly is a bit tricky.

I'll walk you through the entire process of understanding how the Loaders work, implementing a sane base class for your Loaders, implementing `CursorLoader` with all issues fixed and extending it to allow multiple notification Uris. It'll be a long post so grab a cup of your favourite beverage.

## Loaders 101

Loader should do three things:

1. Load data in background thread.
2. Cache the loaded data, so you won't reload it after screen orientation change.
3. If applicable, monitor the data source and reload the data when necessary.

The Loader class itself doesn't provide any mechanism for loading the data in background thread. You either have to implement this yourself, or you can subclass the `AsyncTaskLoader`. This covers the first point on our requirements list.

The 2nd point is not handled by `AsyncTaskLoader`. In fact the `AsyncTaskLoader` is far from being fully functional, for example this perfectly reasonable looking implementation won't work:

``` java
public class DasLoader extends AsyncTaskLoader<String> {
  public DasLoader(Context context) {
    super(context);
  }

  @Override
  public String loadInBackground() {
    return "Das";
  }
}
```

## AbstractLoader v1

A good starting point for creating either `CursorLoader` implementation or LoaderCustom.java from SDK samples. Here's the common part of these two implementations, which provides all necessary boilerplate for loading and caching the data:

``` java
public abstract class AbstractLoader<T> extends AsyncTaskLoader<T> {
  T mResult;

  public AbstractLoader(Context context) {
    super(context);
  }

  @Override
  public void deliverResult(T result) {
    if (isReset()) {
      releaseResources(result);
      return;
    }

    T oldResult = mResult;
    mResult = result;

    if (isStarted()) {
      super.deliverResult(result);
    }

    if (oldResult != result && oldResult != null) {
      releaseResources(oldResult);
    }
  }

  @Override
  public void onCanceled(T result) {
    super.onCanceled(result);
    releaseResources(result);
  }

  @Override
  protected void onReset() {
    super.onReset();

    // Ensure the loader is stopped
    onStopLoading();

    releaseResources(mResult);
    mResult = null;
  }

  @Override
  protected void onStartLoading() {
    if (mResult != null) {
      deliverResult(mResult);
    }
    if (takeContentChanged() || mResult == null) {
      forceLoad();
    }
  }

  @Override
  protected void onStopLoading() {
    cancelLoad();
  }

  protected void releaseResources(T result) {
  }
}
```

Why this class is not provided by the framework is a mystery to me, but hey, that's just one more thing you have to know when coding for Android platform. Now you can write your custom Loader like this:

``` java
public class DasLoader extends AbstractLoader<String> {
  public DasLoader(Context context) {
    super(context);
  }

  @Override
  public String loadInBackground() {
    return "Das";
  }
}
```

But why do we need all that code? The key to understanding the Loaders is understanding the expected Loader's behaviour in different states: started, stopped, abandoned and reset. Upon entering each state, the appropriate callback is executed:

* `onStartLoading`: the Loader was created and should either load the data or return cached data.
* `onStopLoading`: the Loader should keep the cached data and monitor the data source for changes, but it shouldn't load the data. This happens for example when users presses home button from your app.
* `onAbandoned`: someone restarted the Loader. New instance of this Loader was created in `onCreateLoader` callback in your `Fragment`/`Activity`/whatever and loads new data. The abandoned Loader should keep the data until the new Loader loads and delivers it's data. There is no point of monitoring data source or reloading the data in abandoned Loader - the data will be loaded by the new instance. When new Loader delivers it's data this Loader will be reset.
* `onReset`: the data previously loaded by this Loader are no longer used and should be cleaned up. This Loader might be started again, so make sure you clean up also any old state in your Loader implementation.

The `AsyncTaskLoader` provides additional callback:

* `onCancelled`: called after data loading when it turns out that this data is no longer needed, for example when the `AsyncTask` executing your `onLoadInBackground` was cancelled. In this callback you should take care of releasing resources.

Since the releasing resources should be also performed in `onReset` callback and in our deliverResults implementation, our AbstractLoader class provides handy `releaseResources()` callback for closing your `Cursor`s, file handles, etc.

Now let's walk through our `AbstractLoader` implementation. When someone starts our Loader using `LoaderManager.initLoader()`, the `onStartLoading` is called:

``` java
  T mResult;

  // ...

  @Override
  protected void onStartLoading() {
    if (mResult != null) {
      deliverResult(mResult);
    }
    if (takeContentChanged() || mResult == null) {
      forceLoad();
    }
  }
```

We keep the loaded data in `mResult` member of our `AbstractLoader`. If we have already loaded the data, we can just deliver the results to Loader clients. If the cache is empty or the Loader was notified about new data available for fetching, we force data reload by calling `forceLoad()` method. It starts `AsyncTask` which executes `loadInBackground` in background thread and the result is passed to `deliverResults` function:

``` java
  @Override
  public void deliverResult(T result) {
    if (isReset()) {
      releaseResources(result);
      return;
    }

    T oldResult = mResult;
    mResult = result;

    if (isStarted()) {
      super.deliverResult(result);
    }

    if (oldResult != result && oldResult != null) {
      releaseResources(oldResult);
    }
  }
```

A lot of interesting things happen here. First, we check if the loader was put into `reset` state. In this state all the previous resources were already released, so we just need to take care of newly loaded data. Then we swap the data in cache, call `deliverResults` in Loader and then release the resources for previously cached data.

When the Fragment or Activity with active Loader is stopped, the Loaders are also put in the stopped state. It means that they should keep the cached data, monitor if this data is still valid, but they should not actively load the data or deliver the results to UI thread. In terms of `AsyncTaskLoader` it means that any running `AsyncTasks` should be cancelled:

``` java
  @Override
  protected void onStopLoading() {
    cancelLoad();
  }
```

Current implementation of `AsyncTaskLoader` do not interrupt the active tasks, it only marks that the results of these tasks should not be delivered to the UI thread. However, the results might require some resource releasing, so the `onCancelled` callback is called:

``` java
  @Override
  public void onCanceled(T result) {
    super.onCanceled(result);
    releaseResources(result);
  }
```

The last callback we have to implement is `onReset`:

```java
  @Override
  protected void onReset() {
    super.onReset();

    // Ensure the loader is stopped
    onStopLoading();

    releaseResources(mResult);
    mResult = null;
  }
```

There are two important things here. First, the Loader can be moved to reset state from started state, which means it can still have active `AsyncTasks` executing `loadInBackground`. We need to stop them first. Then, as per the specified contract, we have to release the resources and clear the cache.

What about `onAbandoned` callback? AbstractLoader doesn't monitor any data source by itself, so this callback doesn't have to be implemented.

## CursorLoader

So how would we implement observing a data source and automatic reloading? Let's see how would the `CursorLoader` implementation look like had we used our AbstractLoader as a base class (literally; if you merge MyCursorLoader and AbstractLoader code samples from this post, you'll get exactly the CursorLoader implementation from support-v4):

```java
public class MyCursorLoader extends AbstractLoader<Cursor> {
  private final ForceLoadContentObserver mObserver;

  public MyCursorLoader(Context context) {
    super(context);
    mObserver = new ForceLoadContentObserver();
  }

  // bunch of setters for uri, projection, selection, etc. Omitted for brevity

  @Override
  public Cursor loadInBackground() {
    Cursor cursor = getContext().getContentResolver().query(mUri, mProjection, mSelection,
        mSelectionArgs, mSortOrder);
    if (cursor != null) {
      // Ensure the cursor window is filled
      cursor.getCount();
      cursor.registerContentObserver(mObserver);
    }
    return cursor;
  }
}
```

This implementation has two bugs and one kind-of-feature. Let's start with the last one.

`onStartLoading` contract specifies, that you should start monitoring the data source upon entering this state. But let's think what would happen if you had a query that takes 200ms to run and your data source would change every 150ms. The loader would never deliver any data, because every load request would be cancelled in middle of `loadInBackground` execution by our content observer.

I guess that's why the Android implementation of `CursorLoader` registers the observer after the data is loaded. This way the first results are delivered as soon as possible, but for subsequent loads the data is delivered only when data didn't change during loading. I'm not sure if it was intentional, or this behavior was implemented by accident, but it makes sense to me, so let's adjust our Loaders contract and implement this behavior in our AbstractLoader.

But if you look closely, the `CursorLoader` implementation violates even this updated contract. Remember that `loadInBackground` and `deliverResults` are executed on separate threads. So what would happen if the data observer is triggered after `registerContentObserver` call, but before the `deliverResults`? We'd get exactly the same behavior we'd get had we registered the ContentObserver in `onStartLoading` - the loader would never deliver it's data. That's the first bug.

The second issue with `CursorLoader` implementation is violation of `onAbandon` callback contract. If someone calls restartLoader and the content observer is triggered, the abandoned Loader instance will happily reload it's data just to throw it away.

You can dismiss it as something that would happen only 1% of the time and has negligible impact, and if we were talking about application code, I'd agree with you, but IMO library code that will be used by thousands of developers should be held to a higher standard.

## Fixing CursorLoader

Here's the wrap up of changes in behavior:
1. Register `ContentObserver` after the first data is delivered, not after the first data is loaded.
2. Unregister `ContentObserver` in `onAbandon`.

The first point requires changes to `deliverResult` method, so it makes sense to modify our AbstractLoader:

``` java
  @Override
  public void deliverResult(T result) {
    if (isReset()) {
      releaseResources(result);
      return;
    }

    T oldResult = mResult;
    mResult = result;

    if (isStarted()) {
      if (oldResult != result) {
        onNewDataDelivered(result);
      }
      super.deliverResult(result);
    }

    if (oldResult != result && oldResult != null) {
      releaseResources(oldResult);
    }
  }

  protected void onNewDataDelivered(T data) {
  }
```

Our `CursorLoader` implementation would look like this:

``` java
public class MyCursorLoader extends AbstractLoader<Cursor> {
  private final ForceLoadContentObserver mObserver;

  public MyCursorLoader(Context context) {
    super(context);
    mObserver = new ForceLoadContentObserver();
  }

  // bunch of setters for uri, projection, selection, etc. Omitted for brevity

  @Override
  public Cursor loadInBackground() {
    Cursor cursor = getContext().getContentResolver().query(mUri, mProjection, mSelection,
        mSelectionArgs, mSortOrder);
    if (cursor != null) {
      // Ensure the cursor window is filled
      cursor.getCount();
    }
    return cursor;
  }

  @Override
  protected void onNewDataDelivered(Cursor data) {
    super.onNewDataDelivered(data);
    data.registerContentObserver(mObserver);
  }
}
```

The second part - unregistering observer in `onAbandon` - is tricky. It's illegal to call `Cursor.unregisterContentObserver` with observer that wasn't registered and the `onAbandon` can be called when the `deliverResults` wasn't called (see `AsyncTaskLoader.dispatchOnLoadComplete()` implementation). One solution would be keeping the set of Cursors that were registered, but it's not optimal. Instead, we can create a proxy ContentObserver that can be enabled or disabled:

``` java
public class DisableableContentObserver extends ContentObserver {
  private final ContentObserver mWrappedObserver;
  private boolean mIsEnabled = true;

  public DisableableContentObserver(ContentObserver wrappedObserver) {
    super(new Handler());
    mWrappedObserver = wrappedObserver;
  }

  @Override
  public void onChange(boolean selfChange) {
    if (mIsEnabled) {
      mWrappedObserver.onChange(selfChange);
    }
  }

  public void setEnabled(boolean isEnabled) {
    mIsEnabled = isEnabled;
  }
}
```

``` java
public class MyCursorLoader extends AbstractLoader<Cursor> {
  private final DisableableContentObserver mObserver;

  public MyCursorLoader(Context context) {
    super(context);
    mObserver = new DisableableContentObserver(new ForceLoadContentObserver());
  }

  // bunch of setters for uri, projection, selection, etc. Omitted for brevity

  @Override
  protected void onStartLoading() {
    mObserver.setEnabled(true);
    super.onStartLoading();
  }

  @Override
  protected void onAbandon() {
    mObserver.setEnabled(false);
  }

  @Override
  protected void onReset() {
    mObserver.setEnabled(false);
    super.onReset();
  }

  @Override
  public Cursor loadInBackground() {
    Cursor cursor = getContext().getContentResolver().query(mUri, mProjection, mSelection,
        mSelectionArgs, mSortOrder);
    if (cursor != null) {
      // Ensure the cursor window is filled
      cursor.getCount();
    }
    return cursor;
  }

  @Override
  protected void onNewDataDelivered(Cursor data) {
    super.onNewDataDelivered(data);
    data.registerContentObserver(mObserver);
  }
}
```

## AbstractObservingLoader

The `CursorLoader` is a bit special case, because the `Cursor` itself contains `ContentObservable`. In most cases however the content observers and loaded data would be completely separated. For these cases it would be useful to have a base class for Loader which registers some `ContentObservers`:

``` java
public abstract class AbstractObservingLoader<T> extends AbstractLoader<T> {
  protected final DisableableContentObserver mObserver;
  private boolean mIsRegistered;

  public AbstractObservingLoader(Context context) {
    super(context);
    mObserver = new DisableableContentObserver(new ForceLoadContentObserver());
  }

  @Override
  protected void onStartLoading() {
    mObserver.setEnabled(true);
    super.onStartLoading();
  }

  @Override
  protected void onAbandon() {
    mObserver.setEnabled(false);
    unregisterObserver(mObserver);
    mIsRegistered = false;
  }

  @Override
  protected void onReset() {
    mObserver.setEnabled(false);
    unregisterObserver(mObserver);
    mIsRegistered = false;z
    super.onReset();
  }

  @Override
  protected void onNewDataDelivered(T data) {
    if (!mIsRegistered) {
      mIsRegistered = true;
      registerObserver(mObserver);
    }
  }

  protected abstract void registerObserver(ContentObserver observer);
  protected abstract void unregisterObserver(ContentObserver observer);
}
```

We need to keep the registered state in our Loader, because the default `Observable` implementation doesn't like registering the same observer twice or unregistering not registered observer.

Now we can use this class as a base for a Loader which should be reloaded when one of specified `Uri`s is triggered:

``` java
public class MyCursorLoader extends AbstractObservingLoader<Cursor> {

  public MyCursorLoader(Context context) {
    super(context);
  }

  // bunch of setters for uri, projection, selection, etc. Omitted for brevity

  @Override
  public Cursor loadInBackground() {
    Cursor cursor = getContext().getContentResolver().query(mUri, mProjection, mSelection,
        mSelectionArgs, mSortOrder);
    if (cursor != null) {
      // Ensure the cursor window is filled
      cursor.getCount();
    }
    return cursor;
  }

  @Override
  protected void onNewDataDelivered(Cursor data) {
    super.onNewDataDelivered(data);
    data.registerContentObserver(mObserver);
  }

  @Override
  protected void registerObserver(ContentObserver observer) {
    for (Uri uri : mObservedUris) {
      getContext().getContentResolver().registerContentObserver(uri, true, observer);
    }
  }

  @Override
  protected void unregisterObserver(ContentObserver observer) {
    getContext().getContentResolver().unregisterContentObserver(observer);
  }
}
```

## Conclusions

I think the `Loaders` aren't as bad as some people think and say. Four Loader states might seem complicated at first, but if you think about Android `Activity` lifecycle they make perfect sense and they are something you'd have to implement yourself, with a high probability of mucking things up. The only thing lacking is documentation and sane base classes for extensions, something I hope I delivered through this blog post.

[+CommonsWare](https://plus.google.com/114205433913370454414) wrote few weeks ago that [he considers Loader to be a failed abstraction](http://commonsware.com/blog/2014/03/31/cwac-loaderex-failed-abstractions.html), mostly because the interface assumes there is a single object which notifies the Loader about new data. He concluded his post with the following sentence:

{% blockquote %}
In my case, if I am going to have some singleton manager object, with distinct data objects per operation, I am going to use something more flexible than Loader, such as an event bus.
{% endblockquote %}

Extending `AbstractObservingLoader` to load some data from `SQLiteDatabase` and subscribe to some event bus for model change events should be trivial, and you'd get a lot of things for free - performing loads in background, cancelling loads, caching results, invalidating cache, and so on.

Having said that, `Loaders` are not solution to every single problem. They are coupled with activity lifecycle, so they are not suitable for long running tasks that should not be interrupted when user navigates away. In these cases the `IntentService`, or some other `Service` implementation is a better choice.
