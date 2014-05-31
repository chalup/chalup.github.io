---
layout: post
title: "How (not to) test your QML application for Symbian"
date: 2012-01-22T16:15:00+01:00
categories:
 - Nokia
 - Testing
 - QML
 - Symbian
 - Qt
---


First of all by QML I do not mean [this](http://sneezy.cs.nott.ac.uk/QML/), I mean [this](http://developer.qt.nokia.com/doc/qt-4.8/qtquick.html): a UI module of Qt, the cross-platform framework. The gals and guys at Nokia figured out that modern user interface cannot be fully described by static layout in a XML file. Microsoft figured out that too, but they chickened out and only extended XML a bit and added an 'a' to file extension to make it look like something new. Nokians took a step further and created new language for declarative UI based on JavaScript called QML. 

The QML UI components can be defined in two ways: it can be a QML file composed of other components (for instance that's the usual way to define the main UI file) or it can be a C++ extension. Both ways can be used together to create a plugin, which can be imported to your project. 

And at last we reach the intended topic of this post: testing. What happens if some QML file defining a component is missing? What happens if the whole plugin is missing or the version of this plugin is lower than the one required by application? QML files are interpreted during runtime, so of course you get the runtime error. In the best scenario it limits the functionality of your app, in the worst case it renders it completely unusable. 

But hey, you can catch most of those errors simply by clicking through your application, right? Not exactly, doing so only tells you that in works on one particular device. You might have some plugins already installed, but not included in application's package and your app will work only on the devices which happen to have those plugins, which is not very likely. 

{% img center /images/works-on-my-machine-starburst_2.png %}
That's exactly the error I made when I published the first version of "Nu, Pogodi!". I submitted for Q&A process an application with dependencies to Qt Components 1.1, build with the latest Qt SDK. I've tested it thoroughly on some devices I had access to and via [Remote Device Access](http://www.developer.nokia.com/Devices/Remote_device_access/) service (which BTW rocks; I wish there was a similar service for Android) and everything worked fine. The application was rejected by Q&A, because at the end of 2011 there was some [technical issues with Nokia Store and latest Qt](http://support.publish.nokia.com/?p=3766&type=news) and I was told to rebuild my application with old SDK, which included only Qt Components 1.0. I've tested my game again and everything worked so I published it to Nokia Store. Few days later I received first reviews - all negative, along the lines "doesn't work, beware". 

Qt Smart Installer partially prevents those errors, but you still might shoot yourself in the foot in some cases. My game had dependencies to Qt Components 1.1, but the pkg file declared dependency to version 1.0, because it was created with old SDK. When my customers installed the game, the smart installer ensured only that version 1.0 is installed, but my game needed newer version and failed during runtime. I didn't caught this during testing, because all of my devices had latest Qt Components installed. 

That was the "How not to test your QML application" part, now let's get to solution. It's really simple: downgrade all the stuff needed by your application to versions defined in pkg file. To check the current versions of Qt libraries and plugins I recommend using an excellent [QtInfo tool](http://projects.developer.nokia.com/qtinfo). To downgrade Qt you need the sis files distributed with [old Qt SDK versions](ftp://ftp.qt.nokia.com/qtsdk/).

This simple steps should ensure that your application will work properly on all supported devices. Nevertheless, you should prepare for failure and handle all runtime errors in a user friendly way. But that's the topic for another post...
