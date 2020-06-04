---
title: Simple Note Tagging with Notetags
date: 2018-07-07
categories: [Code]
tags: [python, development, workstation, productivity]
description: A quick overview of Notetags, a python project for interacting with tags in plain text files.
aliases:
- /blog/simple-note-tagging-with-notetags.html
---

Reading yet another [thread](https://news.ycombinator.com/item?id=17532094) on favorite note-taking apps had reminded me of a Python learning project I had worked on a while back to solve just this problem (at least for myself). My needs are simpler than most dictated in the thread (and many other threads), but at the end of the day how this is solved for each person is entirely a matter of preference. For my needs, all that I desired was a simple way to browse the files (which arguably can be improved in this project) as well as a sustainable, long-term method of interacting with these files. For this reason, a lot of application-based note-taking services were out of the question as they generally met and exceeded the usability aspects (UI, note search) but were generally lacking in the ability to up and pull my data out of them. 

![ntdemo](images/notetags-demo.gif)

[Notetags](https://github.com/komish/notetags) breaks down the problem to the basics. Tagging systems exist explicitly to solve the issue of search - making sure to return relevant results. In this particula case, there's nothing but a substring match taking place so the tags themselves need to provide the value to the user to make this effective - and that can be defined however the user wants.

![ntconfig](images/notetags-config.png)

The config file is quite straight-forward, defining a set of file extensions that you want parsed as well as your identifer. The application will also build this for you if it's not already in place by using the `genconfig` command.  Ultimately the tag flexibility is a requirement depending on your chosen file format - some tag markers may work better in certain formats than others.

File syncing is not built into the utility because it's largely unnecessary. The parser works on flat files, so backing up your files using a sync service of your choosing is the path forward. Alternatively, having your files stored in a service with a built-in rendering engine (such as Github/Gitlab) makes consuming your notes a bit nicer. That said, I typically search for a file with contents that I need, and then open the raw file in an editor with a built in Markdown rendering engine such as [Atom.io](https://atom.io/) or [VSCode](https://code.visualstudio.com/). Even using a utility like [Pandoc](https://pandoc.org/) to automatically render the notes and pop them open in a browser is only a few bash functions away.

The application can be locally installed using Python 3 directly from Github but the eventual goal is to get this integrated into the Python Package Index to expedite installs. 

