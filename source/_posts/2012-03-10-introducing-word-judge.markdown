---
layout: post
title: "Introducing: Word Judge"
date: 2012-03-10T11:17:00+01:00
categories:
 - Word Judge
 - Android
 - Release
---

I enjoy playing Scrabble and other word games like WordSquared of Word with Friends and I think I'm quite good at them for an amateur - my average score in 2-player Scrabble game is around 330 points. I do not have a tournament aspirations, because memorizing word lists or best stems doesn't fit my definition of fun, but I'm always in for a casual game.

The only thing that bothers me during these casual games are occasional, but unpleasant arguments - how do you spell given word or what is some 3 letter combination an obscure word or gibberish. Polish language have both [declension](http://en.wikipedia.org/wiki/Declension) and [conjugation](http://en.wikipedia.org/wiki/Conjugation) with a lot of irregularities, so there are plenty of things to argue about.

Most of the times we sort things out simply by checking the word spelling on the Internet, but there are situations when you can't do that, for example when you're abroad and don't have wi-fi access and roaming data access price is extraorbitant, or you're in the middle of the outback with no connectivity whatsoever. Without that possibility you have to find a compromise, and boy, that's not easy when you challenge someones 7-letter word on two triple-word bonus tiles.

That's why I created Word Judge - an ultimate way to settle all word-related disputes. The application contains full dictionary of valid words and short word list with definitions. Dictionary is shipped with the application, so you don't need internet connectivity to check if the word can be used in a word game. Currently the application is available only for Android devices, but I'm going to release Symbian (and maybe Harmattan?) version soon.

<table class="separator" style="clear: both; text-align: center;"><tbody><tr><td>{% img center /images/screenshot1.png %}</td><td>{% img center /images/screenshot2.png %}</td><td>{% img center /images/screenshot3.png %}</td></tr></tbody></table>

Unlike many other word game helpers, Word Judge doesn't contain anagrammer tool. It's not an oversight, it didn't add it for two reasons. First of all I don't think that such functionality should be bundled with the application, which is basically a dictionary. You use a dictionary to check the spelling, not to cheat. The second reason is more prosaic - I don't like the UI of any anagrammer tools I found. It's usually a jumble of checkboxes and radio buttons and two fields for board and rack tiles. Even if you figure out what all those controls do, these tools don't really solve the problem, which is finding the best move. It's not an easy problem, even if you find a convenient way to import current game state to the application ([AR](http://en.wikipedia.org/wiki/Augmented_reality) maybe?). It's certainly a good idea for a separate application, but not for a part of a dictionary app.

I released one version of my application for every supported language (currently only [English](https://play.google.com/store/apps/details?id=com.chalup.WordJudgeEN) and [Polish](https://play.google.com/store/apps/details?id=com.chalup.WordJudgePL)). I considered setting up a service with downloadable dictionaries, but I decided against it, because it would needlessly complicate the application and I think that using multiple dictionaries is quite rare use case. Let me know if I'm wrong, I might change my mind. Also, if you like the idea of my application and want me to create a Word Judge for your language, [send me an email](mailto:jerzy.chalupski@gmail.com). Unfortunately, since the app is free I cannot offer you anything more than a mention in application description and "About" window.

I was sure from the start that I won't charge money for this app, but I pondered for quite a long time if I should use ads. On one hand they are visually displeasing and take scarce screen real estate. On the other hand, I want to see for myself how much revenue they generate - the testimonies of other developers vary from ecstatic to disappointed. In the end I decided to add a small banner as an experiment.

This post is already getting too long, so let me just mention that in the next week or so I'm going to write about stuff I learned while working on this application. I hope you'll enjoy the reading. Meanwhile, dust of your Scrabble board, [download my app](https://play.google.com/store/apps/details?id=com.chalup.WordJudgeEN) and enjoy an argument-free game!
