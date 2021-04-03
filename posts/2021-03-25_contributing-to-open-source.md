---
title: Contributing To Open Source Software
date: 2021-03-25
categories: [Thoughts]
tags: [development, open source]
description: Reflections on the effort put forth to contribute to open source.
---

![splash](/images/contrib-to-open-source-splash.jpg)

I’ve just submitted a [pull request](https://github.com/lxc/lxd/pull/8592) to a
[major open source project](https://github.com/lxc/lxd). [Edit: it merged!] ~Technically it hasn’t
merged, so there’s still time for me to become a liar!~

That might read as a bit of an odd statement given that my current `$DayJob` has
me working in the open source space frequently and constantly.

What I really mean is that I contributed a pull request with a significant
amount of code to a repository with which I have very little experience. Or I
guess I should really say “had” little experience, given the recent deep-dive I
had to do to commit to the project...although I’d argue that I’ve really only
scratched a tiny bit of the surface of the project’s overall code base.

I initially got involved during the 2020
[Hacktoberfest](https://hacktoberfest.digitalocean.com/) season. Despite recent
[negative press](https://news.ycombinator.com/item?id=24658052&p=2) that the
Hacktoberfest project received in th 2020 calendar year, I’ve initially
participated in 2018 as a reason to explore new code bases. Reading a code base
is an invaluable way to gain a better understanding of how languages work, glean
best-practices and interesting coding styles, and ultimately practice the skill
of becoming familiar with a new technology (which is something we constantly
have to do as systems administrators and developers).

Contributing to open source, however, has its challenges, and I hit several of
them in working on this contribution that I want to reflect upon here. Time is
the Ultimate Challenge And it affects everyone. It’s very easy to go to a
project’s issue board and demand the world. The reality is that, for some of
these projects, the maintainers are volunteering their extra time to be able to
fulfill feature requests.

I’m being very specific about that wording. Maintainers are volunteering their
extra time to work on these projects. It’s fairly common to refer to time being
spent on these projects as the maintainer’s free time, but I’d argue that’s a
mischaracterization of their effort. No usage of time is free; all usage of time
has a cost. These maintainers are choosing to spend some time working on a
utility that they’re passionate about and make it available to the world. It’s
important to recognize that this is time not spent with families or on other
responsibilities. 

## Transferring Knowledge (to yourself) is Important

![notes](/images/contrib-to-open-source-notes.jpg)

Work on the code submitted in this pull request happened across weeks, or maybe
even months. Quite frankly I’ve lost track. But as I spent a few hours of an
evening a couple of times a week working on the project, I realized in the early
session that I was unable to store my research solely in my brain.

I commonly keep a log for project work, and this project was no exception. Every
session included time spent reading the previous session’s notes, tasks, and
thoughts, and then some time at the end of the session to serialize the same
information to help the next session ramp up more quickly. This proved to be
absolutely vital - I just couldn’t remember exactly what I was working on in the
previous session otherwise, and that usually meant time wasted trying to figure
out why something was broken.

These notes also contained my broken understanding of various concepts as I
performed research. I imagine if I were to go back now and read the log from top
to bottom, I’d inevitably see an evolution of understanding that would be
fascinating to try and parse.

## Everything Has a Ramp Up

![issuetags](/images/contrib-to-open-source-issuetags.png)

Issue trackers have a way of categorizing the work associated with implementing
a given feature or fixing a given bug. A lot of times (especially during
Hacktoberfest), this is used to help invite newcomers to a code repository.

It’s easy to get hung up with a task being flagged as “Easy” that you then
struggle to implement. That hang up could take a toll on your own perception of
your ability to continue with the issue. You shouldn’t let this discourage you.

The reality is that the folks have measured the amount of work necessary to
solve a given issue and have determined that it doesn’t require extravagant new
changes. That doesn’t imply that the issue is trivial, or a one-line change.
What that implies is that the issue is good for someone just starting to get
familiar with the code base because it doesn’t require having a holistic view of
everything to determine how to move forward. 

Getting familiar with a code base of any size can be a challenge. Don’t allow
yourself to get hung up on something being flagged as easy that then poses a bit
of a challenge. The challenge is the fun.

## Guiding Lights for Future Contributions

If I had to provide myself some advice to help guide my
contributions to open source in the future, I’d suggest a couple of things.

**Play with the application code base before you commit to fixing an issue.**

Playing with the application itself is already a requirement, and is therefore
assumed.

Realistically, I made several assumptions with regards to how things worked and
fixing that cost me some time. If I had been familiar with how to make changes
to the code base before I had committed to the issue, I would have saved some
time figuring out logistics about “how the build workflows work”, or “how the
test workflows work”, or “what things I have to change to implement the feature”
.

Granted, playing with a code base before you have an assigned task is going to
cost you time, and you’re potentially already short on time. But this does start
to bring substance to the idea behind contributing to a single project or subset
of projects, as opposed to random projects. I feel that familiarity really helps
cut down your time to contribution delivery, and so finding a project that you
can really start to become familiar with is valuable to them and to you. 

Work with a project that you’re interested in. Keep adding value to that
project. When you’re ready to move on to the next, do so. Rinse and repeat.

**Do not be afraid to ask questions.**

The maintainers of the project to which I contributed were incredibly valuable
in this. The interactions, honestly, were a model of what fantastic
maintainership looks like. From my perspective, the maintainers were more than
willing to offer guidance, and were also careful (though I have no idea if this
was intentional) to avoid giving me a direct “solution”. That allowed me to keep
discovering the code base, whereas providing a direct implementation for me to
go write doesn’t really let me do that discovery. They also provided a road map
from the very start. 

If you have questions, feel like you’re not following the right design or train
of thought, or just need to be refocused - ask questions and participate in
discussion.

**Read and Re-read the problem statement.**

This seems obvious. The reality is that I read the issue multiple times trying
to get a foothold on the ask. I went in with a picture that I thought was
complete. About a week or two before I submitted my pull request, I realized
that I had parsed some of the problem statement incorrectly, which led to a lot
of extra “searching” through the code base as I tried to find logic that I was
encouraged to reuse.

That’s my own fault. Once I parsed things correctly, quite a few of the changes
required to implement the feature seemed to fall into place.

It’s worth your while to make sure you understand the problem fully, and to
constantly check your understanding throughout your work. Your understanding of
the problem might also evolve as you start to become more familiar with the code
base.

Go Contribute! With that said, don’t be afraid of participating in open source
projects that interest you. It’s a great ride. Shoutout to the [Stéphane
Graber](https://stgraber.org/) ([GitHub](https://github.com/stgraber)) for the
guidance and encouragement!


---
_Photos credit from external sources in order of appearance._

_(splash) Photo by [Safar
Safarov](https://unsplash.com/@codestorm?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
on
[Unsplash](https://unsplash.com/s/photos/coding?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)_

_(notes) Photo by [David
Travis](https://unsplash.com/@dtravisphd?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
on
[Unsplash](https://unsplash.com/s/photos/notes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)_
