---
title: "MacOS Big Sur - and the case of the missing entries in Spotlight"
publishDate: 2021-04-19
categories: [Spotlight]
tags: [macos, big-sur, micro]
description: "Fixing a bug where MacOS Big Sur doesn't show apps in the Spotlight results."
---

I heavily rely on Spotlight to start applications when I'm on MacOS. I generally
disable a majority of things that end up in the Spotlight index and only leave
applications as that's the primary thing I'm wanting to be accessible when I use
spotlight via its keyboard shortcut `cmd+space`.

I recently went through the upgrade procedure to get MacOS Big Sur on one of my
machines and noticed that my applications were completely missing from
Spotlight. After some brief searching, I came across a stack exchange[1] that
seemed to have a solution that works. For bookmarking purposes, I'll record the
commands from that entry that worked for me (should I ever need to do it again).

The gist is basically retriggering an index by stopping and starting spotlight.

Stop Spotlight:

```shell
sudo mdutil -a -i off
```

Start Spotlight:

```shell
sudo mdutil -a -i on 
```

The other commands to load and unload Spotlight did not work on my machine as I
have some Integrity Protection system that must be enabled. I don't really have
details on it, but since simply stopping and starting resolved my issue, I left
it at that.

[1]Source: [Apple Stack
Exchange](https://apple.stackexchange.com/questions/62715/applications-dont-show-up-in-spotlight)
