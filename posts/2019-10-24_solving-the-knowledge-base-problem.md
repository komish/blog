---
title: Solving the Knowledge Base Problem
date: 2019-10-24
categories: [Productivity]
tags: [learning, productivity]
description: Challenges in maintaining an effective personal note-taking system.
aliases:
- /blog/solving-the-knowledge-base-problem.html
---

As my day-to-day responsibilities shift, I'm finding that my knowledge base system needs to evolve to suit new needs. This is clearly humanity's greatest challenge... as a quick search on hacker news produces a [massive](https://news.ycombinator.com/item?id=21332957) [set](https://news.ycombinator.com/item?id=19098926) of [results](https://news.ycombinator.com/item?id=20819478) on the [topic](https://news.ycombinator.com/item?id=21108527) (just in the last [year](https://news.ycombinator.com/item?id=21242229)) revolving around the "how",  "what" and "why" of personal notes. The reality is that everyone has a different answer because this flow of processing data and distilling it for later use is very personal. What's ubiquitous in my research of this particular topic is that most have dedicated a large amount of cycles to solving this problem for themselves, and are constantly willing to evaluate alternatives to their workflow to make it better (or else they wouldn't be in these discussions in the first place).

To that end, here's the summary(-ish) of my thoughts in figuring out how to manage this particular problem for myself.

### What's Solved?

**Managing To-Do Lists**.  

I was discussing this whole _problem_ with a [friend](https://twitter.com/tonyskapunk) of mine who is a fan of [Emacs](https://www.gnu.org/software/emacs/) and the rest was history. He's tried to get me to use it before (and I've failed), but the reality is that the power-house that is [Org Mode](https://orgmode.org/) cannot be rivaled by any system that exists anywhere else. I know _now_ what failed me in my first attempt to use Emacs at all -- learning too much in too short of a time has an impact on productivity. The reality is that you find yourself in a "race to be productive" pretty much daily, where lack of productivity irks you and anything that blocks productivity gets the axe. To clarify, it's a self-imposed pressure to be productive that can conflict with learning a new tool. And I would feel comfortable going on the record saying that no Emacs user has ever been able to look me in the eye and tell me that Emacs doesn't have a large learning curve. I also don't know many Emacs users, so take that for what it's worth. 

![orgmode](/images/kb-orgmode.png)

I've relegated Org Mode to simple todo-list management with a couple of additional todo items for flexibility. I also use the agenda to get a great consecutive view of how I'm making progress on things throughout the week. It also limits my required keybindings to work into muscle memory. 

As far as what could be better, I add a scheduled time to a todo item to get it into my agenda, but as I use nested todo items in some cases, sub-todos need their own scheduled time in order to make it to my agenda view. I haven't invested any time to solving this, but ultimately I could use less nesting to solve this problem. I probably over nest as it is.

**Editing Markdown** 

Before I used org-mode for anything, I never considered taking notes in anything _other_ than markdown. It's just simple to write, I know it well (so there's nothing new to learn), and it's universal (or at least very close to being so). A key component of any knowledge system is the ability to render to markdown for backups... so if you start with markdown then this is (by definition) solved. That said, what irks me about markdown is that it's absolutely terrible to read without rendering into another format. Side-by-side editors are super common, but having to switch my view away from where I'm writing can be frustrating. 

![typora](/images/kb-typora.png)

**[Typora](https://www.typora.io/)** solves this problem by rendering as you type. This has proven to be invaluable to editing markdown files for me. It has some behavioral quirks as it does the live rendering completely in place, but for the most part they've been more than manageable. The downside? It's not [open-source software](https://github.com/typora/typora-issues/issues/890), and they do have a plan to charge for a license at some point in the future. I don't mind paying for software, but only time will tell how the pricing model pans out. And you'll bet that I'll look for open-source software before I shell out money. 

There are a couple of apps that behave in a similar fashion, though they don't completely live render. I'm documenting them for future use. [StackEdit](https://stackedit.io/) is a web application that is incredibly flexible for markdown editing. The other, more recent find is [QOwnNotes](https://www.qownnotes.org/), which I've not vetted as a fully-fledged note system with a markdown editor embedded is not something I really _need_. At least--not for my upcoming approach.

### What's Unsolved

Pretty much everything else. The reality is that a knowledge base is a collection of notes _for your future reference_. And yet, I don't find myself referring to my notes frequently for anything other than sharing information with team members and friends. I'll admit that I do keep a lot of copy-pastable entries (read: commands that let me repeat a given task when testing things) that I'll refer to, but at that point my notes are really just a scratch pad of commands with a slight bit of capture context mixed in. The challenge here is making those notes more meaningful.

Additionally, the concept of "maintaining notes" implies a centralized location for all of your thoughts that can be accessed from anywhere. This in mind, I think that I do need some kind read-only access from devices that aren't computers (read: smartphones), but it isn't a deal break. For productivity on a smartphone, all I really _believe_ I need is the ability to jot something down, or schedule a task to be completed. That system can be independent from my solution to the knowledge base problem, but if they play well together -- bonus points.

### What Hasn't Worked

Full-blown note systems, at least for the most part, haven't worked for me. I've tried a _ton_ of applications, but in the most recent effort I've mostly spent time with [Notion](https://www.notion.so/) and [Joplin](https://joplinapp.org/). Both had their advantages, could export all of my data to markdown (for pick-up-and-go style migrations), and generally had a simple workflow fully encompassed in the application.

**Notion** had a clean user interface and a very interesting system for adding elements (input a `/` character to insert a particular element or object into your document). Context was easy to preserve using their database system which allowed you create subpages on a parent page, and embed a bunch of visibile metadata in an easy to see format. The largest drawback for me was that subpages didn't show up in the sidebar heirarachy. That, and some difficulty working with code blocks and generally manipulating "blocks" (their representation of an "item" on a page) left something to be desired. 

**Jopin** also had a clean user experience and gives us a pure markdown editing experience. There are integrations with different sync services (though I only ever used the filesystem sync, which is effectively a "save all files" feature), and it has an excellent "watch" system that allows you to edit a document in another editor (Typora for me) and have Joplin capture those changes to store/save/sync. 

![joplin](/images/kb-joplin.png)

The detractors here are that I found myself getting disorganized over time as my tags didn't really provide much value when looking for content (not a Joplin problem, really), and a few UI bugs that would cause the render pane to fall out of sync (or jitter) when typing. I couldn't quite nail down the cause or get it to occur consistently which means I didnt' open a bug report unfortunately. And of course, this is a side-by-side editor which doesn't work well for me, and while the "open in external application" worked well... it's still yet _another_ app to open and another window to tab through. Context-switching is expensive.

### What's Intruiging

A lot of my research on this topic has drawn my attention to a few things that I find to be completely missing from my workflows historically.

* **Spaced Repetition**, or reintroducing concepts over intervals of time. 
* **Simple Outputs**, or entries into notes that have been pre-filtered and simplified before ever getting written down. The key here is to reduce the length of a given thought that makes it into a note.
* **Log Book**, or a daily log of data, thoughts, experiences.
* **Public Knowledge**, or maintaining knowledge base files in a public place.
* **Mind Mapping**, or maintaining relational information for each piece of information added to the system.

##### On Spaced Repetition

This makes perfect sense. Learning is similar to building muscle. Cramming is rarely effective, and the goal is long-term retention. The best way to do this is to review the content over time, or receiver refreshers of your notes in their respective contexts.

Solving this can be difficult. It requires your content be in an easily-repeatable format. Long-form content is too high of a time investment to review at a regular interval (hence, **simple inputs**). That said, maintaining long-form content is valuable for, say, passing your information to a peer who needs to build the entire context from beginning to end.

Some notable tools in this arena (based on reading through Hacker News) are flash card applications like [Anki](https://apps.ankiweb.net/) and [Org Drill](https://orgmode.org/worg/org-contrib/org-drill.html). Fundamentally, I like the concepts of spaced repetition and think it's important to include in whatever might be next for me, but it won't be the first thing I try to integrate as it has some dependencies on adding additional applications into my flow. 

##### On Simple Outputs

This is tough. I tend to be incredibly verbose (just look at this blog post!) and I also believe setting up context is incredibly important to learning. I think, however, that having short-form content can really have a significant impact on retention. It forces you to distill the information you're receiving and only document concepts. There's probably room for both long and short-form content in your knowledge base, but what you use for retention should not be your long-form content. Either way, if you want to implement spaced repetition, you need short-form content that plays nicely with forcing yourself to re-read things at a later date.

##### On Log Books

This idea came from a link in one of the Hacker News threads to a university engineering [PDF](https://www.webpages.uidaho.edu/mindworks/Capstone Design/Project Guides/Logbook_Handout.pdf) on how to maintain an engineering log book. I've indicated already that tagging is something I don't use effectively to find information, but I think part of that could be due to implementation details in these note-taking apps. If you shift your approach to a daily, journal-style writing, tagging takes a completely different value. With a good seach system, you'd be able to search through your notes and get a chronological representation of your notes on that given tag. This stream of data in chronological order builds **context**. If you combine this with **short outputs**, you have a good system that feeds into **spaced repetition**. 

##### On Public Knowledge

This is particularly intruiging. A lot of people say that they maintain a blog as their knowledge base, but I have trouble believe that's the case. A blog that takes a "knowledge base" format tends to have less content than I would expect in a knowledge base. That is, it contains the "pet projects" of a knowledge base, typically around a subject that someone's exploring. They could be ramblings on solving complex problems for a subject, or a direct how-to guide. What they tend **not** to be is a stream of output as a result of guzzling from the information fire-hose while learning something new. I should clarify, I've seen quite a few examples of public knowledge bases that are _exactly_ that. But they're usually just a master list of topics (think folder hierarchy for your notes) sorting a bunch of links to notes that have been rendered into a pretty format for display. I can hardly call that a blog, or equate a blog to a public knowledge base. The key detractor to maintaining a public knowledge base is imposter syndrome, and the need for private data (say a temporary set of credentials) to live in my notes in some cases where I need to change computers while working on a project.

##### On Mind Mapping

I'm not sure I have much to say on this subject other than it seems interesting. I'm not sure how to maintain this kind of relationship and still be able to render to an easy format to pick-up-and-move to another solution (if needed). Either way, there are many options in this space but [Digraph](https://github.com/emwalker/digraph) got my eye. I felt it needed an honorable mention should I decide to try it some day.

### My Minimum Requirements

We're somewhat past trying to find a solution to fit _requirements_, but I wrote these down so I find them to be valuable to document. I think these requirements are fairly common, or so the trend of new note-taking apps that fit them would suggest. 

* Must support code blocks
* Rich text or Markdown+in-place renders
* Writes done with a computer
* Reads on any device (not a hard requirement)
* Default to private (not shared) but easy to share
* Must sync with minimal effort
* Must not require self-hosting (I'm generally ok with self-hosting a service, but I don't want to maintain a system for this - that costs time)
* Must be exportable to markdown (or similar), retaining context.

### The TL;DR

[This post](https://news.ycombinator.com/item?id=21333446) caught my attention the most. It's from the developer behind [Dnote](https://www.getdnote.com/download/) which is an interesting tool that enforces short outputs and spaced repetition. The core principles that influenced the design of Dnote are what I found to be missing the most from my note-taking system. 

![dnote](/images/kb-dnote.png)

To that end, while I won't be trying Dnote immediately (it's a net-new workflow, and I won't have the time to mess with it before I need to be productive with it), it's high on the priority list. For starters, I'll likely try the maintaining an engineering log. It naturally fits with my OrgMode-based workflow and has the lowest barrier of entry (spaced repetition with org-drill, search with org-categories and tags, and hopefully the discipline to keep the outputs small). 

Happy Learning!



