---
layout: post
comments: true
title: "Android LayoutInflater gotcha"
date: 2012-02-22T09:26:00+01:00
categories:
 - Gotcha
 - Android
 - Layout
---

Many custom Adapter tutorials contain subtle error which can be hard to find and fix. Even [efficient list adapter sample from Android SDK](http://developer.android.com/resources/samples/ApiDemos/src/com/example/android/apis/view/List14.html) contains this bug. If you compile and run the sample without any changes you should see something like this:

{% img center /images/original.png %}

There's nothing wrong with the list on this screenshot, as long as that's the look you want. But what if you want the list items to be wider? Let's change the list item layout:

``` xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Copyright (C) 2007 The Android Open Source Project

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
  
          http://www.apache.org/licenses/LICENSE-2.0
  
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
-->

<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="horizontal"
    android:layout_width="match_parent"
    android:layout_height="150dip">

    <ImageView android:id="@+id/icon"
        android:layout_width="48dip"
        android:layout_height="48dip" />

    <TextView android:id="@+id/text"
        android:layout_gravity="center_vertical"
        android:layout_width="0dip"
        android:layout_weight="1.0"
        android:layout_height="wrap_content" />

</LinearLayout>
```

What's changed? Nothing, nada, zilch, zip. No changes whatsoever:

{% img center /images/changed.png %}

You can use hierarchy viewer tool to verify that the list item height was not set correctly.

{% img center /images/hierarchy.png %}

There's obviously nothing wrong with the layout xml, so let's take a look at the code:

``` java
/*
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.apis.view;

import android.app.ListActivity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import android.widget.ImageView;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap;
import com.example.android.apis.R;

/**
 * Demonstrates how to write an efficient list adapter. The adapter used in this example binds
 * to an ImageView and to a TextView for each row in the list.
 *
 * To work efficiently the adapter implemented here uses two techniques:
 * - It reuses the convertView passed to getView() to avoid inflating View when it is not necessary
 * - It uses the ViewHolder pattern to avoid calling findViewById() when it is not necessary
 *
 * The ViewHolder pattern consists in storing a data structure in the tag of the view returned by
 * getView(). This data structures contains references to the views we want to bind data to, thus
 * avoiding calls to findViewById() every time getView() is invoked.
 */
public class List14 extends ListActivity {

    private static class EfficientAdapter extends BaseAdapter {
        private LayoutInflater mInflater;
        private Bitmap mIcon1;
        private Bitmap mIcon2;

        public EfficientAdapter(Context context) {
            // Cache the LayoutInflate to avoid asking for a new one each time.
            mInflater = LayoutInflater.from(context);

            // Icons bound to the rows.
            mIcon1 = BitmapFactory.decodeResource(context.getResources(), R.drawable.icon48x48_1);
            mIcon2 = BitmapFactory.decodeResource(context.getResources(), R.drawable.icon48x48_2);
        }

        /**
         * The number of items in the list is determined by the number of speeches
         * in our array.
         *
         * @see android.widget.ListAdapter#getCount()
         */
        public int getCount() {
            return DATA.length;
        }

        /**
         * Since the data comes from an array, just returning the index is
         * sufficent to get at the data. If we were using a more complex data
         * structure, we would return whatever object represents one row in the
         * list.
         *
         * @see android.widget.ListAdapter#getItem(int)
         */
        public Object getItem(int position) {
            return position;
        }

        /**
         * Use the array index as a unique id.
         *
         * @see android.widget.ListAdapter#getItemId(int)
         */
        public long getItemId(int position) {
            return position;
        }

        /**
         * Make a view to hold each row.
         *
         * @see android.widget.ListAdapter#getView(int, android.view.View,
         *      android.view.ViewGroup)
         */
        public View getView(int position, View convertView, ViewGroup parent) {
            // A ViewHolder keeps references to children views to avoid unneccessary calls
            // to findViewById() on each row.
            ViewHolder holder;

            // When convertView is not null, we can reuse it directly, there is no need
            // to reinflate it. We only inflate a new View when the convertView supplied
            // by ListView is null.
            if (convertView == null) {
                convertView = mInflater.inflate(R.layout.list_item_icon_text, null);

                // Creates a ViewHolder and store references to the two children views
                // we want to bind data to.
                holder = new ViewHolder();
                holder.text = (TextView) convertView.findViewById(R.id.text);
                holder.icon = (ImageView) convertView.findViewById(R.id.icon);

                convertView.setTag(holder);
            } else {
                // Get the ViewHolder back to get fast access to the TextView
                // and the ImageView.
                holder = (ViewHolder) convertView.getTag();
            }

            // Bind the data efficiently with the holder.
            holder.text.setText(DATA[position]);
            holder.icon.setImageBitmap((position & 1) == 1 ? mIcon1 : mIcon2);

            return convertView;
        }

        static class ViewHolder {
            TextView text;
            ImageView icon;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setListAdapter(new EfficientAdapter(this));
    }

    private static final String[] DATA = Cheeses.sCheeseStrings;
}
```

I've highlighted the problematic line. It turns out that you have to use another overload of LayoutInflater.inflate method:

``` java
convertView = mInflater.inflate(R.layout.list_item_icon_text, parent, false);
```

We set the attachToRoot to false, because we just want to properly intialize LayoutParams for the LinearLayout of the item and let the ListView to add the inflated views wherever it needs. In fact, setting it to true causes exception to be thrown from AdapterView:

``` java
java.lang.UnsupportedOperationException: addView(View, LayoutParams) is not supported in AdapterView
    at android.widget.AdapterView.addView(AdapterView.java:461)
    at android.view.LayoutInflater.inflate(LayoutInflater.java:416)
    at android.view.LayoutInflater.inflate(LayoutInflater.java:320)
    at android.view.LayoutInflater.inflate(LayoutInflater.java:276)
    at com.fu.InflaterBugActivity$EfficientAdapter.getView(InflaterBugActivity.java:77)
    at android.widget.AbsListView.obtainView(AbsListView.java:1430)
    at android.widget.ListView.makeAndAddView(ListView.java:1745)
    at android.widget.ListView.fillDown(ListView.java:670)
    at android.widget.ListView.fillFromTop(ListView.java:727)
    at android.widget.ListView.layoutChildren(ListView.java:1598)
    at android.widget.AbsListView.onLayout(AbsListView.java:1260)
    at android.view.View.layout(View.java:7175)
    at android.widget.FrameLayout.onLayout(FrameLayout.java:338)
    at android.view.View.layout(View.java:7175)
    at android.widget.LinearLayout.setChildFrame(LinearLayout.java:1254)
    at android.widget.LinearLayout.layoutVertical(LinearLayout.java:1130)
    at android.widget.LinearLayout.onLayout(LinearLayout.java:1047)
    at android.view.View.layout(View.java:7175)
    at android.widget.FrameLayout.onLayout(FrameLayout.java:338)
    at android.view.View.layout(View.java:7175)
    at android.view.ViewRoot.performTraversals(ViewRoot.java:1140)
    at android.view.ViewRoot.handleMessage(ViewRoot.java:1859)
    at android.os.Handler.dispatchMessage(Handler.java:99)
    at android.os.Looper.loop(Looper.java:123)
    at android.app.ActivityThread.main(ActivityThread.java:3683)
    at java.lang.reflect.Method.invokeNative(Native Method)
    at java.lang.reflect.Method.invoke(Method.java:507)
    at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:839)
    at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:597)
    at dalvik.system.NativeStart.main(Native Method)
```

Here's the application screenshot after the change: 

{% img center /images/fixed.png %}

Ugly, but that's exactly what we should get after setting layout height to 150dip.
