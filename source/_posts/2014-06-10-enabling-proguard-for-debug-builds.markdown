---
layout: post
title: "ProGuard in ant debug builds"
date: 2014-06-10 9:24:00 +0200
comments: true
categories:
 - ProGuard
 - Android
 - ant
---

The post title raises two questions: "why would you want to use ProGuard in debug builds?" and "why the hell are you still using ant?!".

The answer for the first question is simple, so let's start with that one. A while ago we hit the [infamous 64k method limit](https://code.google.com/p/android/issues/detail?id=20814). The most reasonable option is to use ProGuard to remove unused code, especially from the dependencies. For some unreasonable option, see the Jesse Wilson's comments in the linked bug report.

And why ant instead of Maven, gradle, buck or any other non-antique build tool? We've started the project in dark ages (in 2011), when the android Maven plugin was still under heavy development and we encontered several issues with it. Ant builds just worked, so we set it up and nobody had to touch it for several months. At one point we considered switching to gradle, because setting up some annotation processors with ant was a pain in the ass, but again there were some issues with using gradle in our setup at the time (IIRC it was not possible to use local aar dependencies, and the builds were sooooooo slooooooow), so we did not switch.

It all boils down to this: I can spend several hours working on some useful feature or library or I can use this time to switch to another build system. Until the latter option gives me some real benefits, I'd rather work on some features.

Anyways, using ProGuard for IDE builds is easy: go to Project Structure, Facets, and fill appropriate options on ProGuard tab for your project. That's fine for developers workflow, but not for CI.

To make ProGuard work with ant you need to customize your build.xml. First, if this is your first cusomization, change the version tag in build.xml as recommended:

``` xml
<!-- version-tag: custom -->
```

Then override `-debug-obfuscation-check` and `-release-obfuscation-check` targets:

``` xml
<target name="-set-proguard-config">
    <condition property="proguard.config" value="proguard.cfg" else="proguard_debug.cfg">
        <isfalse value="${build.is.packaging.debug}"/>
    </condition>
</target>

<target name="-debug-obfuscation-check" depends="-set-proguard-config">
    <!-- enable proguard even in debug mode -->
    <property name="proguard.enabled" value="true"/>
    <echo>proguard.config is ${proguard.config}</echo>

    <!-- Secondary dx input (jar files) is empty since all the jar files will be in the obfuscated jar -->
    <path id="out.dex.jar.input.ref" />
</target>

<target name="-release-obfuscation-check" depends="-set-proguard-config">
    <echo level="info">proguard.config is ${proguard.config}</echo>
    <condition property="proguard.enabled" value="true" else="false">
        <and>
            <isset property="build.is.mode.release" />
            <isset property="proguard.config" />
        </and>
    </condition>
    <if condition="${proguard.enabled}">
        <then>
            <echo level="info">Proguard.config is enabled</echo>
            <!-- Secondary dx input (jar files) is empty since all the
                 jar files will be in the obfuscated jar -->
            <path id="out.dex.jar.input.ref" />
        </then>
    </if>
</target>
```

Note that I've also introduced a `-set-proguard-config` task to be able to select different configuration for debug and release builds. We do not want to do obfuscation or advanced optimisations in debug, a simple dead code pruning is all we need. Since ant properties are immutable, this means that you **HAVE TO** remove proguard.config from your ant.properties.

I'm not exactly sure when this happened, but at some point our build times skyrocketed to over 3 minutes. It's fine for release or CI scripts, but absolutely unnacceptable for developers workflow. Fortunately it was enough to bump the heap size for Proguard. In Android Studio go to Settings, Compiler, Android Compilers and pass `-Xmx1024m` to ProGuard VM options.
