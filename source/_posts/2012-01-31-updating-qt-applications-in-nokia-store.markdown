---
layout: post
title: "Updating Qt applications in Nokia Store"
date: 2012-01-31T21:10:00+01:00
categories:
 - Nokia Store
 - Qt
---


Every Symbian Qt application in Nokia Store consists of two parts: metadata and content files. Metadata is the information about the application visible in Nokia Store, and content files are applications binaries, i.e. sis file. Both parts are separate entities, can be updated independently and have separate Quality Assurance process. It stands to reason: why would anyone have to verify the application binary when you correct a typo in applications  description?

But sometimes you might want to change the description and the binary at the same time. For example I screwed up testing of the first version of my ["Nu, Pogodi!"](/blog/2012/01/20/introducing-nu-pogodi/) game and first few reviews were negative with "Doesn't work, shows only black screen" comment. I fixed the issue, published new binary and added "Version 1.0.1 fixes the black screen issue." text to description. The metadata QA finished earlier, but still the old, malfunctioning binaries were served. Guess what happened - the next review was also negative, this time with "Black screen, cannot download version 1.0.1" text. Joy.

So the point is, currently there is no way to update both parts of content at the same time. The solution recommended by Nokia Publish Support is to publish the binaries first, because the QA for that part is longer than for metadata and update the metadata when binaries pass QA.
