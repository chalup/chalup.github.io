---
layout: post
comments: true
title: "Introducing: Nu, Pogodi!"
date: 2012-01-20T12:05:00+01:00
categories:
 - Game
 - Nokia
 - NuPogodi
 - QML
 - Qt
 - Release
---

{% img center /images/nupogodi.png %}

"Nu, pogodi!" is the first application I've published in Nokia Store (or any other app store, in fact). It's a remake of a classic handheld console game I used to play in my childhood: you had to place a wolf with a basket under one of four roosts to catch the eggs rolling from them. Despite the extreme simplicity and the obvious flaw in the game plot (namely: what the hell does the wolf need the eggs for?) the game was quite addictive and I spent many hours listening to the hypnotizing ticking of the falling eggs (if you played this game you know what I'm talking about).

The handheld console I based my game on is actually a Russian clone of "Egg" game from Nintendo's "Game & Watch" game series. The main difference is the graphics - instead of fox and hen the Russian clone featured the Wolf and the Hare from a "Nu, pogodi!" cartoon - hence the name of the game.

{% img center /images/handhelds.jpg %}

At the beginning of 2011 I wanted to check out the Qt Quick, which was advertised by Nokia as the best thing since sliced bread. I never liked the go-through-a-boring-tutorials way of learning new things, so I started writing UI for a simple game instead. Few weeks later Nokia announced [Qt Quick Competition](http://www.developer.nokia.com/Community/Wiki/The_Quick_Competition_2011Q1) - an event promoting Qt Quick introduced in Qt 4.7. I've entered the competition with the early version of my game under the name ["Nu, Pagadi!"](http://projects.developer.nokia.com/PAGADI) (which is, as I learned later, incorrect - apparently in Russian sometimes you write an 'o', but pronounce it as 'a'), which didn't won me anything, but at least I had a motivation to work on the game. In accordance with the competition rules I've published my code under OSS license and forgot about the whole deal.

In November 2011 I've stumbled upon a "Soviet Eggs" game in Nokia Store. It seems that some company forked my competition entry, added a splash screen and the menu and charged 2 euros for it. I've watched the gameplay videos on YouTube, and thought I can do much better version than them. I polished my game, added sound effects, better looking menu and new game mode which resembles the gameplay of original game much more than the one included in the competition entry. All those changes took me about one week worth of evenings and one weekend. Subsequentially I've [screwed up testing](/blog/2012/01/22/how-not-to-test-your-qml-application), published to Nokia Store a game which silently crashed on 90% of the phones, fixed the problem, and then I screwed up again, this time when [publishing the update](/blog/2012/01/31/updating-qt-applications-in-nokia-store).

Despite the initial issues the game reached top 10 bestseller list in two weeks and stayed there ever since. Try it yourself!

[{% img center /images/nupogodi-banner.png %}](http://store.ovi.com/content/219800)

