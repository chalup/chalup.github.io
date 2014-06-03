---
layout: post
comments: true
title: " Weekend hack: viewing markdown attachments in GMail on Android"
date: 2013-03-05T23:02:00+01:00
categories:
 - GMail
 - Android
 - markdown
 - Release
---

Recently I wanted to open a markdown email attachment on my Nexus 4, but after clicking "readme.md" instead of seeing the file contents I saw this message:

{% img center /images/no_app_dialog.png %}

I downloaded few apps from Google Play, but the message was still appearing. The same applications could open a local markdown file, so I went back to GMail app to download the attachment, but another unpleasant surprise awaited me:

{% img center /images/no_overflow.png %}

There is no "overflow" menu on the attachment (see the screenshot below), which means I couldn't access the "Save" option, so I could open it as a local file.

{% img center /images/save_menu.png %}

At this point I was:

1. Pissed off, because, cmon, GMail is probably the most used app working on the mature operating system and I can't download a fucking file with it.
1. Curious, because it looked liked an interesting issue with GMail app.

The first clue was in the GMail logs in the logcat:

```
03-04 21:12:50.477: W/Gmail(13823): Unable to find supporting activity. mime-type: application/octet-stream, uri: content://gmail-ls/jerzy.chalupski@gmail.com/messages/121/attachments/0.1/BEST/false, normalized mime-type: application/octet-stream normalized uri: content://gmail-ls/jerzy.chalupski@gmail.com/messages/121/attachments/0.1/BEST/false
```

Note the Uri: there is no file name and no file extension, and the mime-type is a generic application/octet-stream (most likely because the "md" extension is not present in [libcore.net.MimeUtils](http://grepcode.com/file/repo1.maven.org/maven2/com.google.okhttp/okhttp/20120626/libcore/net/MimeUtils.java)). The markdown viewers/editors I downloaded probably register intent filters for specific file extensions, so they don't know they could handle this file. It sucks big time, because it means that the applications for viewing files with non-standard extensions would have to register for application/octet-stream mime-type, and even though they handle very specific file types they all appear in the app chooser dialog for many different file types, which defeats the whole purpose of Android Intent system and reduces the UX.

My first idea was to create an "GMail Attachment Forwarder" app which registers for any content from GMail, gets the attachment mail by querying the [`DISPLAY_NAME`](http://developer.android.com/reference/android/provider/MediaStore.MediaColumns.html#DISPLAY_NAME) column on the Uri supplied by GMail, save this information along with original GMail Uri in public [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html), and start the activity using Uri exposed by my [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html) which does contain attachment name. This [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html) should also forward any action to original GMail Uri.

Unfortunatly I was foiled by the [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html)'s permissions systems: the Activity in my app was temporarily granted with the read permissions for GMail's [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html), but this permissions did not extend to my [`ContentProvider`](http://developer.android.com/reference/android/content/ContentProvider.html) and the app I was forwarding the attachment to failed because of the insufficient permissions.

This approach didn't work, but having a catch-all handler for GMail attachments unlocked the attachment actions. I also noticed that when the attachment is downloaded, the GMail uses a slightly different intent:

```
03-04 23:05:34.005: I/ActivityManager(526): START u0 {act=android.intent.action.VIEW dat=file:///storage/emulated/0/Download/readme-1.md typ=application/octet-stream flg=0x80001 cmp=com.chalup.markdownviewer/.MainActivity} from pid 3063
```

This led me to plan B: have an app which enables the attachment download and use other apps to open downloaded attachments. I renamed my app to GMail Attachment Unlocker, cleared the manifest and source folder leaving only a single, automatically closing activity:

``` xml
<application
  android:allowBackup="true"
  android:label="@string/app_name"
  android:theme="@android:style/Theme.NoDisplay" >
  <activity
    android:name="com.chalup.gmailattachmentunlocker.MainActivity"
    android:label="@string/app_name" >
    <intent-filter>
      <action android:name="android.intent.action.VIEW" />

      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />

      <data
        android:host="gmail-ls"
        android:mimeType="*/*"
        android:scheme="content" />
    </intent-filter>
  </activity>
</application>
```

``` java
public class MainActivity extends Activity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    finish();
  }

}
```

The full source code is [available on my Github](https://github.com/chalup/gmail-attachment-unlocker) (althought there really isn't much more than what is posted here). In the end I also ended up writing my own markdown viewer (source code in [another repo on my Github](https://github.com/chalup/android-markdown-viewer)), because none of the apps I have downloaded properly rendered tags (hint: you have to use [`WebView.loadDataWithBaseUrl`](http://developer.android.com/reference/android/webkit/WebView.html#loadDataWithBaseURL%28java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String%29) instead of [`WebView.loadData`](http://developer.android.com/reference/android/webkit/WebView.html#loadData%28java.lang.String, java.lang.String, java.lang.String%29)).
