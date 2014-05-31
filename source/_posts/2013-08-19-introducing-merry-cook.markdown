---
layout: post
title: "Introducing: Merry Cook"
date: 2013-08-19T21:10:00+02:00
categories:
 - Game
 - QML
 - Symbian
 - Merry Cook
 - Qt
---

{% img center /images/ss3.png %}

After a long hiatus since November 2011 I have released another clone of classic Russian handheld game from the '80s - Merry Cook. I knew that the "Nu, Pogodi!" code wasn't my top achievement, and I had to force myself into diving into it, but I feel it was worth it. Few things I think I did right this time:

* **Do not keep *any* game logic in QML**. Qt has an excellent state machine framework, which makes writing the game logic in C++ relatively easy.
* **Keep the QML/C++ interface as simple as possible**. Send signals from QML to C++ when user takes some action and update the QML UI from the C++ side by changing QProperties on some context property object. I've actually used two objects for that, because it made testing a bit easier.
* **Unit tests**. I've set up the testing harness using gmock/gtest and I've used it to unit test some things. I probably would have been fine without them, since Merry Cook is a very simple but a) it forced me to divide stuff into more manageable classes and b) it gave me a sense of accomplishing something early. It's funny, because even though I'm absolutely conscious of the latter fact, I think it gave me enough boost to get to the point where I had moved forward with implementation and polishing, because I really wanted to publish this game.
* **QProperty helper**. I wrote an abominable macro for reducing the QProperty boilerplate:
<script src="https://gist.github.com/chalup/6267728.js"></script></li>

Things still on my TODO list:

* **More tests**. Besides unit tests I'd also like to write some integration tests for the state machine setup and connections, but I didn't have time to think how this should be done without making too much state public just for testing. Maybe next time.
* **Refactor "Nu, Pogodi!"**. I jumped straight into new project, but I should have started with refactoring the old crap. On the other hand, it might have sucked out all the motivation out of me, and had I done it, I wouldn't have been writing this post right now. So, maybe next time.
* **Passing enums to QML**. I have no idea what I did wrong, but I couldn't get the QML to see my C++ enums. I've resorted to passing them as simple ints and using magic numbers on QML side, but it's definitely something I should fix. Obviously not now, but next time.

Anyways, I'm really happy with the final results, especially with the gameplay experience, which I think mimics the original game very well. Try it yourself!
