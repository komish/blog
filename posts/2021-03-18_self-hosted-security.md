---
title: Self-Hosted Security
date: 2021-03-18
categories: [Thoughts]
tags: [selfhosting, security]
description: Self-hosted applications can be security risks, but should that stop you from using them?
---

I came across this thread called [Self-Hosting
Git](https://news.ycombinator.com/item?id=26490179) recently. I'm sure at least
one reader finds that source ironic after my recent post on[RSS
feeds](/posts/2021/03/13/active-consumption-of-articles-on-the-web/). 

The article poses a somewhat-aggressive stance that self-hosting a git service
(cgit) is easy, and should be considered by anyone as the better option to
existing SaaS.

What I found most interesting about the article is this point by user.
[XorNot](https://news.ycombinator.com/user?id=XorNot)

> Recently I just finished tearing down all my self-host services. Things facing
> the public internet might be convenient, but heck if I want to face that
> security nightmare in an ongoing way.
>
> All my git repos now live in a "git" folder I share amongst my fileserver and
> other machines with syncthing, hosting only the bare repos. If I need pull
> requests or issue tracking, it's got to be something that goes with the
> repository - as it always should've been, really. 

There is a key point being made here: making software applications accessible
over the internet poses a non-trivial security threat.

I feel like this has always been the case.

The reality is that software has bugs, and bugs can carry security implications.
In the open-source world, those security implications often carry real
consequences with minimal to no recourse. By "recourse", I simply mean with
regards to mitigating the risk or damage caused by a security issue. The
open-source world does not lack resources eager to help resolve a bug or
security issue, but self-hosting places the mitigation effort directly to your
desk.

On the other hand, SaaS providers have the same risk. The key distinctions are
that these providers (a) have teams constantly evaluating the platform to reduce
the attack surface (or so I hope, or want to believe), and (2) have teams to
help mitigate the risk and perform damage control. This paints the picture that
the user only needs to worry about the risk of an outage caused by a security
incident in a given provider's application. Sure, I'll need to mitigate the
damage (think: rotate passwords if the authentication services were impacted),
but ultimately that's a minimal action to take for the busy professional.

I'm generally the sole user of most of my self-hosted services (which,
admittedly, I have very few). As the sole user,  I'm quite tolerant to outages
should they arise, but I've not had to experience extended outages that weren't
planned. I have some automation to help me move from version to version, but I
hardly do this as actively as I should (given the premise further in the thread
that constantly scanning for security vulnerabilities in the tools you self-host
seems like a requirement - I don't think so personally). And finally, I have a
backup strategy in place. I'm generally either willing to lose the data (i.e.
it's transient), or I back up the data in its simplest form. Backing up the data
in its simplest form is what I care about. In other words, in the case of a
catastrophic failure where my applications are running or my data is stored, my
only concern (as a busy professional) is that the data exists and is usable.
This is another reason to dabble in services that are easy to serialize to
[plain-text](https://plaintextproject.online/). That also gives credence to the
comment author's new code forge configuration.

I like where the commenter landed with regards to their code hosting. I used a
similar set up for a long period of time, and have plans to set up plain
file-servers in my home lab in lieu of hefty applications that add extra
features. With that said, hosting an internet-facing self-hosted application
shouldn't scare you. They're usually fun to use and always fun to explore. But
knowing that you are the sole maintainer of that service and don't have the time
to actively contribute to the reduction of attack surface, practice good
security fundamentals (good password hygiene, application isolation, etc) to
reduce your risks. And have a basic backup plan focused on the raw data you
need, not the restoration of the service, for anything truly important.
