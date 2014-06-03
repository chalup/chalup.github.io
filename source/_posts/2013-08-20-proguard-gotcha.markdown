---
layout: post
comments: true
title: "Proguard gotcha"
date: 2013-08-20T19:53:00+02:00
categories:
 - Proguard
 - Java
 - Android
 - build system
---

A while ago I wrote about [removing the logs from release builds using Proguard](/blog/2012/10/17/android-protip-remove-debug-logs-from). As usual, I've found a gotcha that might cost you a couple hours of head scratching.

Let's say that we have a code like this somewhere:

``` java
package com.porcupineprogrammer.proguardgotcha;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class MainActivity extends Activity {
  static final String TAG = "ProguardGotcha";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Log.d(TAG, doNotRunOnProduction());
  }

  private String doNotRunOnProduction() {
    Log.e(TAG, "FIRE ZE MISSILES!");

    return "Harmless log message";
  }
}
```

The `doNotRunOnProduction()` method might perform some expensive database query, send some data over the network or launch intercontinental missiles - anyways do something that you don't want to happen in production app. If you run the code on the debug build you'll of course get the following logs.

```
08-20 19:31:34.183    1819-1819/com.porcupineprogrammer.proguardgotcha E/ProguardGotcha: FIRE ZE MISSILES!
08-20 19:31:34.183    1819-1819/com.porcupineprogrammer.proguardgotcha D/ProguardGotcha: Harmless log message
```

Now, let's add Proguard config that removes all the `Log.d()` calls:

```
-assumenosideeffects class android.util.Log {
  public static *** d(...);
}
```

We might expect the `Log.e()` call to be gone as well, but alas, here is what we get:

```
08-20 19:34:45.733    2078-2078/com.porcupineprogrammer.proguardgotcha E/ProguardGotcha: FIRE ZE MISSILES!
```

The key point to understanding what is happening here is the fact that the Proguard does not operate on the source code, but on the compiled bytecode. In this case, what the Proguard processes is more like this code:

``` java
@Override
protected void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);

  String tmp = doNotRunOnProduction();
  Log.d(TAG, tmp);
}
```

One might argue that the temporary variable is not used and Proguard should remove it as well. Actually that might happen if you add some other Proguard configuration settings, but the point of this blog post is that when you specify that you want to remove calls to `Log.d()`, you shouldn't expect that any other calls will be affected. They might, but if your code really launches the missiles (or does something with similar effect for your users), you don't want to bet on this.
