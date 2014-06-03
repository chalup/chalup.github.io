---
layout: post
comments: true
title: "Android SharedPreferences gotcha"
date: 2012-09-05T22:26:00+02:00
categories:
 - Gotcha
 - fragmentation
 - Android
---

I have another gotcha for you. Can you tell what's wrong with the following code?

``` java
public class MyFragment extends Fragment implements OnSharedPreferenceChangeListener {
  private TextView mInfo;
  private SharedPreferences mPreferences;

  public static final String INFO_SP_KEY = "info";
  
  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container,
      Bundle savedInstanceState) {
    return inflater.inflate(R.layout.my_fragment, container, false);
  }

  @Override
  public void onViewCreated(View view, Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mInfo = (TextView) view.findViewById(R.id.info);
  }
  
  @Override
  public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
    if (key.equals(INFO_SP_KEY)) {
      updateInfo();
    }
  }

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    mPreferences = PreferenceManager.getDefaultSharedPreferences(getActivity());
  }

  @Override
  public void onPause() {
    super.onPause();
    mPreferences.unregisterOnSharedPreferenceChangeListener(this);
  }

  @Override
  public void onResume() {
    super.onResume();
    mPreferences.registerOnSharedPreferenceChangeListener(this);
    updateInfo();
  }

  protected void updateInfo() {
    mInfo.setText(getString(R.string.info_text, mPreferences.getInt(INFO_SP_KEY, 0)));
  }
}
```

At first glance everything looks fine and in most cases it will work fine as well. However, if you a) set android:minSdkVersion to 8 or lower and b) change the shared preference from another thread (IntentService, SyncAdapter, etc.), you'll get the following crash:

```
09-05 07:16:58.993: E/AndroidRuntime(403): android.view.ViewRoot$CalledFromWrongThreadException: Only the original thread that created a view hierarchy can touch its views.
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.ViewRoot.checkThread(ViewRoot.java:2802)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.ViewRoot.requestLayout(ViewRoot.java:594)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.view.View.requestLayout(View.java:8125)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.widget.TextView.checkForRelayout(TextView.java:5378)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.widget.TextView.setText(TextView.java:2688)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.widget.TextView.setText(TextView.java:2556)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.widget.TextView.setText(TextView.java:2531)
09-05 07:16:58.993: E/AndroidRuntime(403): at com.porcupineprogrammer.sharedpreferencesgotcha.BaseFragment.updateButtonText(BaseFragment.java:65)
09-05 07:16:58.993: E/AndroidRuntime(403): at com.porcupineprogrammer.sharedpreferencesgotcha.WrongFragment.onSharedPreferenceChanged(WrongFragment.java:12)
09-05 07:16:58.993: E/AndroidRuntime(403): at android.app.ContextImpl$SharedPreferencesImpl$EditorImpl.commit(ContextImpl.java:2830)
09-05 07:16:58.993: E/AndroidRuntime(403): at com.porcupineprogrammer.sharedpreferencesgotcha.BaseFragment$1$1.run(BaseFragment.java:36)
09-05 07:16:58.993: E/AndroidRuntime(403): at java.lang.Thread.run(Thread.java:1096)
```

Fortunately the obvious crashlog is obvious and you can solve this issue in about 5 seconds, by wrapping the UI action in `Activity.runOnUiThread()` method. Morbidly curious may track the root cause of this issue in [GrepCode](http://grepcode.com/file_/repository.grepcode.com/java/ext/com.google.android/android/2.2_r1.1/android/app/ContextImpl.java/?v=diff&id2=2.3_r1#3035). **Tl;dr**: before Gingerbread the listeners are notified in the same thread as the `SharedPreferences.commit()` caller, in later releases `commit()` ensures the notifications are performed in UI thread.

Code of the sample application that demonstrates this issue is [available on my github](https://github.com/chalup/blog-sharedpreferences-gotcha).
