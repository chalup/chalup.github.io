---
layout: post
title: "My shortest-lived project ever"
date: 2014-09-04 21:11:06 +0200
comments: true
categories: 
 - Groovy
 - gradle
 - Android
 - ProGuard
---

Three weeks ago I wrote a [proguard-please](https://github.com/chalup/proguard-please) plugin. I was super excited by this project because:

1. It was a Gradle plugin, something I wanted to play with for quite some time
1. It was written in Groovy, a language I wanted to play with for quite some time
1. It solved a real issue with ProGuard configuration, which was pissing me off for quite some time

On configuring ProGuard
-----------------------
If you're not familiar with ProGuard, here's the basic info: it's a program which prunes the unused code from your compiled Java program. It can also do other stuff like optimization or code obfuscation and repackaging to make the reverse engineering harder. Sounds good? The catch is that ProGuard sometimes cuts out or obfuscates too much code, which usually breaks the app, especially if you rely on reflection. The trick is to configure it correctly for each library you use, but it's not a trivial task.

The general idea for this plugin was to resolve the dependencies of your Android application and try to find the ProGuard configuration for every one of them. Of course the ProGuard config will not magically appear: the idea was to have a repository of configurations developed by the community.

On Gradle
---------
First part of the project went really smooth, thanks to the [amazing documentation](http://www.gradle.org/docs/current/userguide/userguide.html). I didn't need to do any fancy stuff, so I was able to configure the basic scaffolding in no time at all. Docs for android gradle plugin are pretty much non-existent, but using the imported sources and [android-apt](https://bitbucket.org/hvisser/android-apt) plugin by [Hugo Visser](https://twitter.com/botteaap) as a base for Android related tasks I was able to get my plugin up and running.

On Groovy
---------
I saw the Groovy for the first time at KrakDroid conference, when [Wojciech Erbetowski](https://github.com/wojtekerbetowski) converted boring JUnit tests into [RoboSpock](https://github.com/Polidea/RoboSpock) goodness. It looked nice, but when I started coding in Groovy, my love for this language faded.

There are lot of things I take for granted as a Java developer: amazing IDE, instant feedback when I screw something up and documentation for the code under my cursor at my fingertips. Maybe switching to Groovy, Ruby or Python requires some mindset change I haven't fully embraced, but I simply cannot imagine why would I switch to the language that effectively forces me to write my code in Notepad™.

I think the main problem I have with Groovy stems for the fact that there are some APIs that wouldn't typecheck in regular Java. Consider this code:

```groovy
if (!project.android["productFlavors"].isEmpty()) {
    throw new ProjectConfigurationException("The build flavors are not supported yet", null)
}

def obfuscatedVariants = project.android["applicationVariants"].findAll { v -> v.obfuscation != null }
```

It's a classic type of what I call "string typing": depending on the key used in `project.android[]` access you get collection of objects of completely different type. As a consequence, the IDE cannot provide you with autocompletion or documentation for the collection contents.

Another example is the public API of Grgit library. Theoretically you can call `Grgit.clone(...)`, but there is no such method as `clone` in `Grgit` class, instead you have this code:

```groovy
class Grgit {
	private static final Map STATIC_OPERATIONS = [init: InitOp, clone: CloneOp]

	static {
		Grgit.metaClass.static.methodMissing = { name, args ->
			OpSyntaxUtil.tryOp(Grgit, STATIC_OPERATIONS, [] as Object[], name, args)
		}
	}
}	
```

I don't see what's wrong with the good ol' static method and what do you achieve by using `methodMissing` (besides confusing the IDE and breaking autocomplete/javadocs). Maybe I'm just grupy old fart with brain eroded by too long exposure to Java, but Groovy is definitely not a language for me. I'll put up with it if I ever want to write another gradle plugin, but it's not going to be my go to language.

What's up with the blog title?
------------------------------
Few hours after publishing my project, another solution for ProGuard configuration appeared. It turns out, if you use gradle to build your library, you can configure `consumerProguardFiles` property to include in your aar package a ProGuard configuration that should be used by the users of your library. The logical next step is creating the library project containing only the ProGuard configuration for the most popular libraries out there. And that's exactly what [squadleader](https://bitbucket.org/littlerobots/squadleader) project is.

It's not as flexible solution as my [proguard-please](https://github.com/chalup/proguard-please) plugin, but it's much simpler, much easier to contribute to and the net effect is the same. In this light I chose to put my project on hold and redirect developers to squadleader page.

Despite of that, I'm glad I worked on this project. I'm very excited by the fact that you can easily build an useful tool that's incredibly easy to use. Using gradle for a new build system was a great call.
