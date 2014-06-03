---
layout: post
comments: true
title: "Git killer feature: content tracking"
date: 2012-04-17T16:20:00+02:00
categories:
 - DVCS
 - git
 - Mercurial
---

At my current day job I was the first adopter of git and one of the most frequently question I'm asked as "the git guy" is the variation of "why do you use git instead of mercurial?". I usually responded that git was the first distributed VCS I used, and I played for a while with hg and bazaar, but I haven't discovered any significant feature that would make me change my initial choice. Today I have found the case that allows me to give a better answer.

About a month ago I released the [Word Judge](https://play.google.com/store/apps/details?id=com.chalup.WordJudgeEN) application - an offline word validator for Scrabble and other word games. Initially I was working only on one version of Word Judge with polish dictionary, so I had one line of code in my git repository:

{% img center /images/1.png %}

When polish version was ready, I decided that I might as well release the english version, because it would require only minor changes: changing app icon and dictionary file. It turned out that I also have to change the application package, so both versions of Word Judge could be installed at the same time. The changes were in fact minor, but included a lot of renaming (package name is mirrored by the directory structure):

{% img center /images/2.png %}

Later on I decided to add ads to my application. First, I've added the necessary code to master (i.e. polish) branch:

{% img center /images/3.png %}

I switched to english branch, typed `git merge master --no-commit`, and was very surprised to see just a few conflicts in binary files (icons). All the changes made in java code, **in the renamed files**, were automatically merged. If you still don't get how awesome this is, consider what would I had to do without it:

1. Start the merge
1. Resolve the conflict by selecting "keep deleted files" for every java file changed in the master branch
1. Manually merge every java file from "pl" package and "en" package
1. Delete "pl" package
1. Commit changes

And I would have to do this **every single time** I port the changes between language branches. It's a tedious and error-prone job, and git automatically (automagically?) does it for me. How cool is that? Mightily cool IMHO. Of course if I add some java files in one branch, I have to do move them to correct package in the other branch (hence the `--no-commit` switch in git command above), but most of the conflicts are caused by binary files.

It's also more common case than you might think, i.e. you don't have to write a dictionary supporting multiple languages to run into it. For example if you have a lite and full version of an app, you have exactly the same situation.

Right now my repository looks like this (or it would look like this if the git gui tools didn't suck, but that's another story):

{% img center /images/4.png %}

I can't imagine supporting such structure without automatic merges provided by git, because it tracks **content** instead of **files**. And that's the real killer feature that distinguishes git from other DVCS.
