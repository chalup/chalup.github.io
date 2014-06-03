---
layout: post
comments: true
title: "Android nested Fragments in practice"
date: 2013-03-16T22:03:00+01:00
categories:
 - Fragments
 - Android
---

Last November I wrote about the new feature in rev11 of Android support package - [Fragments nesting](/blog/2012/11/13/android-gets-nested-fragments). Recently I had an opportunity to use this feature in practice and I'd like to share my experience with it.

The basics are simple: each [`FragmentActivity`](http://developer.android.com/reference/android/support/v4/app/FragmentActivity.html) and each [`Fragment`](http://developer.android.com/reference/android/support/v4/app/Fragment.html) has it's own [`FragmentManager`](http://developer.android.com/reference/android/support/v4/app/FragmentManager.html). Inside the Fragment you may call [`getFragmentManager()`](http://developer.android.com/reference/android/support/v4/app/Fragment.html#getFragmentManager%28%29) to get the `FragmentManager` this `Fragment` was added to, or [`getChildFragmentManager()`](http://developer.android.com/reference/android/support/v4/app/Fragment.html#getChildFragmentManager%28%29) to get the `FragmentManager` which can be used to nest `Fragments` inside this `Fragment`. This basic flow works fine, but I have found two issues.

If you have a `Fragment` with nested `Fragments` and you save its state with [`saveFragmentInstanceState()`](http://developer.android.com/reference/android/support/v4/app/FragmentManager.html#saveFragmentInstanceState%28android.support.v4.app.Fragment%29) and try to use it in [`setInitialSavedState()`](http://developer.android.com/reference/android/support/v4/app/Fragment.html#setInitialSavedState%28android.support.v4.app.Fragment.SavedState%29) on another instance of this `Fragment`, you'll get the `BadParcelableException` from `onCreate`. Fortunately it's an obvious bug which is easy to fix: you just need to set the correct `ClassLoader` for a `Bundle` containing this `Fragment`'s state. There is a [patch for it in support library project Gerrit](https://android-review.googlesource.com/#/c/40760/), and if you need this fix ASAP you may use [this fork of support lib on Github](https://github.com/futuresimple/android-support-v4).

The second issue is related with the `Fragments` backstack. Inside each `FragmentManager` you may build stack of `Fragments` with [`FragmentTransaction.addToBackStack()`](http://developer.android.com/reference/android/support/v4/app/FragmentTransaction.html#addToBackStack%28java.lang.String%29) and later on use [`popBackStack()`](http://developer.android.com/reference/android/support/v4/app/FragmentManager.html#popBackStack%28%29) to go back to the previous state. Pressing hardware back key is also supposed to pop the `Fragments` from the back stack, but it doesn't take into account any nested `Fragments`, only `Fragments` added to the `Activity`'s `FragmentManager`. This is not so easy to fix, but you may use the following workaround:

``` java
String FAKE_BACKSTACK_ENTRY = "fakeBackstackEntry";

getFragmentManager()
    .beginTransaction()
    .addToBackStack(null)
    // call replace/add
    .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN)
    .commit();

final FragmentManager rootFragmentManager = getActivity().getSupportFragmentManager();

rootFragmentManager
    .beginTransaction()
    .addToBackStack(null)
    .add(new Fragment(), FAKE_BACKSTACK_ENTRY)
    .commit();

rootFragmentManager.addOnBackStackChangedListener(new OnBackStackChangedListener() {
  @Override
  public void onBackStackChanged() {
    if (rootFragmentManager.findFragmentByTag(FAKE_BACKSTACK_ENTRY) == null) {
      getFragmentManager().popBackStack();
      rootFragmentManager.removeOnBackStackChangedListener(this);
    }
  }
});
```

Quick explanation: together with the actual backstack entry we want to add, we also add the fake backstack entry with empty `Fragment` to top level `FragmentManager` and set up [`OnBackStackChangedListener`](http://developer.android.com/reference/android/support/v4/app/FragmentManager.OnBackStackChangedListener.html). When user presses hardware back button, the fake backstack entry is popped, the backstack listener is triggered and our implementation pops the backstack inside our `Fragment`. The backstack listeners are not persisted throughout the orientation change, so we need to setup it again inside `onCreate()`.

Note that there are two issues with this workaround: it allows adding only one backstack entry and this setup won't be automatically recreated from state saved by `saveFragmentInstanceState()` (fortunately it does work with orientation change). Both issues probably can be solved by some additional hacks, but writing workarounds for workarounds is not something I do unless I really have to, and in this case I neither issue affected me.

Besides those bumps the nested `Fragments` are a real blessing which allows much more cleaner and reusable code.
