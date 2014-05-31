---
layout: post
title: "Background operations on Windows Phone 7"
date: 2012-04-04T13:23:00+02:00
categories:
 - Windows Phone
 - Rant
---

Few weeks ago I was complaining to another developer that Windows Phone applications cannot perform tasks in background when they are not running. That was true few months ago when I learned about Windows Phone 7.0, but he pointed me to MSDN documentation of new WP 7.1 feature: [Background Agents](http://msdn.microsoft.com/en-us/library/hh202961(v=vs.92).aspx).

I clicked the link with my hopes up, but I was immediately shot down with the highlight on the first page: "Background agents are not supported on 256-MB devices". I proceeded to the [overview page](http://msdn.microsoft.com/en-us/library/hh202942(v=vs.92).aspx) and it turned out the highlight from the first page was just the tip of the iceberg. The constraints listed there are just staggering.

First there are the registration issues: you can register background task for the next two weeks and after that period your application have to reschedule the task. I'm not sure why do I have to do this, and at the first glance it looks only like a minor nuisance, until you take into account two other constraints: tasks cannot reschedule themselves and there is a hard limit of scheduled periodic tasks, which can be ridiculously low. Relevant quote from MSDN:

{% blockquote %}
To help maximize the battery life of the device, there is a hard limit on the number of periodic agents that can be scheduled on the phone. It varies per device configuration and can be as low as 6.
{% endblockquote %}

Not a minor nuisance anymore, huh?

This limit is only imposed on periodic agents, which are intended for short, periodic tasks like polling some service or uploading a data. There are also Resource Intensive Agents which can be used for longer tasks like data synchronization, but they have their own set of constraints: the device have to be charging, the battery have to be almost fully charged and there should be a Wi-Fi or PC connection (no cellular data). I think the MSDN note summarizes it quite well:

{% blockquote %}
Due to the constraints on the device that must be met for resource-intensive agents to run, it is possible that the agent will never be run on a particular device. 

(...)Also, resource-intensive agents are run one at a time, so as more applications that use resource-intensive agents are installed on a device, the likelihood of an agent running becomes even less. You should consider this when designing your application.
{% endblockquote %}

I'm going to add to the comment above my own observation: every application can register only one background agent, which can be both periodic agent and resource intensive agent. It means that if you need both types of agents, your resource intensive agent is also affected by the periodic agent hard limit.

It all boils down to this: **you can't rely on the background agents**. You don't have the guarantee that you'll be able to register the agent, which means that you can't use them for critical functionality. So we're exactly where we were after 7.0 release.
