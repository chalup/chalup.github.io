---
layout: post
title: "Gradle - first impressions"
date: 2013-08-18T22:36:00+02:00
categories:
 - gradle
 - Android
 - build system
---

Android Studio kept nagging me about make implementation deprecation, so I decided to try the new build system based on Gradle. At first I obviously hit the [missing Android Support Repository issue](http://developer.android.com/sdk/installing/studio.html#Troubleshooting), but after installing missing component in Android SDK Manager everything was created correctly (AFAIK the v0.2.3 of Android Studio doesn't have this issue anymore). On Mac I also had to set the ANDROID_HOME env variable to be able to build stuff from command line.

The app templates are a bit outdated, for example you might get rid of the libs/android-support-v4.jar, because gradle will anyways use the jar from aforementioned Android Support Repository. The build.gradle also references older support lib and build tools so you should probably bump it to the latest versions.

Adding the dependency to the local jar is trivially easy - we need just one line in dependencies section:

``` groovy
dependencies {
  compile files("libs/gson-2.2.4.jar")
}
```

You can also define dependency to every jar in libs directory:

``` groovy
dependencies {
  compile fileTree(dir: 'libs', include: '*.jar')
}
```

Using code annotation processors (like [butterknife](https://github.com/JakeWharton/butterknife)) is also trivial:

``` groovy
repositories {
  mavenCentral()
}

dependencies {
  compile 'com.jakewharton:butterknife:2.0.1'
}
```

The fist of the gradle's ugly warts is related to the native libs support. You can add the directory with *.so files, the build will succeed, but you'll get the runtime errors when your app will try to call native method. The workaround found on teh interwebs is to copy your native libs into the following directory structure:

```
lib
lib/mips/*.so
lib/other_architectures/*.so
lib/x86/*.so
```

NOTE: there is no typo, the top level directory should be a singular "lib". Then you have to zip the whole thing, rename it to *.jar and include as a regular jar library. Lame, but does the trick.

Let's get back to the good parts. The list of the tasks returned by "gradlew tasks" command contains the installDebug task, but not the installRelease one. This happens, because there is no default apk signing configuration for release builds. The simplest workaround is to use the same configuration as debug builds:

``` groovy
android {
  buildTypes {
    release {
      signingConfig signingConfigs.debug
    }
  }
}
```

But in the real project you should of course define the real signing configuration along the lines: 

``` groovy
android {
  signingConfigs {
    release {
      storeFile file("release.keystore")
      storePassword "XXX"
      keyAlias "XXX"
      keyPassword "XXX"
    }
  }

  buildTypes {
    release {
      signingConfig signingConfigs.release
    }
  }
}
```

The other useful setting that goes into the buildTypes section is the Proguard configuration. Proguard is disabled by default in gradle builds so we need to turn it on for release builds; we also need to specify the rules to be used by Proguard: 

``` groovy
android {
  buildTypes {
    release {
      runProguard true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), file('proguard').listFiles()
      signingConfig signingConfigs.release
    }
  }
}
```

There are two nice things about this configuration: we can easily specify that we want to use the default rules defined in Android SDK and we can specify multiple additional files. In the configuration above I use all files from 'proguard' directory, but you can defined a simple list of files as well. It allows you to create a reusable Proguard config files for the commonly used libraries like [ActionBarSherlock](http://actionbarsherlock.com/) or [google-gson](https://code.google.com/p/google-gson/). 
So far so good. Let's declare the dependency on another project (a.k.a. module):

``` groovy
dependencies {
  compile project(':submoduleA')
}
```

Note that this is also declared in the app project's build.gradle. It's perfectly fine to include this kind of dependency in your app project, but I'm not happy with this solution for declaring dependencies between subprojects, because we're introducing dependencies to main project's structure.

``` groovy
// in build.gradle in main project

dependencies {
  compile project(':submoduleA')
  compile project(':submoduleB')
}

// in build.gradle of submoduleB, which depends on submoduleA

dependencies {
  compile project(':submoduleA')
}
```

It's especially bad when those subprojects are reusable libraries which should be completely separate from your main project. The workaround I read about, but haven't tested myself is creating a local Maven repository and publishing the artifacts from subprojects. AFAIK you still have to publish the artifacts in the right order, so you still have to kind of manually manage your dependencies, which IMO defeats the purpose of having .

I feel I'm missing something elementary. The way I expect it to work is to define in each project what kind of artifacts are created, define artifacts each project depends on and let Gradle figure out the order of building subprojects. Please drop me a line if what I just wrote doesn't make any sense, I expect too much from the build system, or I missed some basic stuff.

Another thing that's not so great is the long startup time. Even getting the list of available tasks for a simple project takes between 5 and 8 seconds on 2012 MBP every single time. I understand why this happens - build configs theoretically can check the weather forecast and use different configuration on a rainy days - and that this overhead is negligible when compared to the actual build time, but every time I stare a this "Loading" prompt I think that this should be somehow cached.

It's time to wrap this blog post up. The main question I asked myself was: is it worth to move to gradle? I'd say that if you have a manageable Maven build, then you shouldn't bother (yet), but it's a huge step forward when compared to ant builds.
