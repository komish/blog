---
title: Using the Solus Operating System
publishDate: 2021-04-03
categories: [Thoughts]
tags: [solus, desktop-linux, operator-systems]
description: My experiences using the Solus operating system.
---

![solussplash](/images/solus-website.png)

I've been giving the [Solus](https://getsol.us/home/) operator system a spin.
Here's a quick run down of how that's gone for me.

Solus is an operating system solely focuses on Desktop use cases. It's a Linux
system that does not care about any other use cases common for linux systems
(such as server use cases). That gives it a unique advantage in that it doesn't
need to be all-encompassing (focusing development efforts to accomodate server
use cases) and really only needs to take into account desktop user experiences.
I think that's a great approach, and is sure to result in a nice user
experience.

I tend to focus on out-of-the-box configurations when it comes to desktop linux
these days. In my younger days, I would certainly find it interesting to dabble
with system configurations, and desktop environment tweaks to make the system
look exactly how I wanted. Today, I change the wallpaper and maybe switch to a
dark/light theme to fit the light levels in the room. Nothing fancy.

The experience is excellent. The UI is quick and snappy and simple. It doesn't
get in the way of general use, and barring some keybinding adjustments (I also
use a personal Macbook Pro for day-to-day things while on the move, and some
shortcuts do unexpected things on the Solus machine), I've had no issues
figuring out how to use the system.

A quick nicety worth mentioning is that terminal notifications inherently show up
as system notifications. A great feature for those long-running commands.

## Installing Software

The system comes with a built-in software center UI that couldn't be easier to
use. The search is quite fast and efficient. One of my favorite things to do is
to run through the various categories available in a visual software center and
see what is offered. It's especially fun to look at the various games features
in "Games" categories because you come across some new FOSS games that you may
not have encountered before. Fans of the
[Lemmings](https://en.wikipedia.org/wiki/Lemmings_(video_game)) game will enjoy
[Pingus](https://pingus.seul.org/).

I also used this machine for some open source development work. The operating
system makes VSCodium (`code-oss`) available which is plenty for the work I was
doing in Golang. The only challenge I had was using [VS Code Remote
Development](https://code.visualstudio.com/docs/remote/remote-overview)
configurations did not support the VSCodium binary as a client. This may be
solved (see:
[github.com/microsoft/vscode-remote-release/issues/391](https://github.com/microsoft/vscode-remote-release/issues/391)
but it was more effort than I was willing to go through at the time. I also
tried getting upstream VSCode from the snap store, but that binary kept crashing
for me and I didn't troubleshoot further (clearly it was late in the evening).

## Third Party Software

Third party software is a section of the software center that carries with it a
caveat that the software may not install cleanly. It's effectively a repository
of software that has been, perhaps, loosely tested but isn't necessarily
guaranteed to install cleanly, or may require more work to get running smoothly.
I'm about to embark on that effort to try and get Android Studio installed for
some [Flutter](https://flutter.dev/docs/get-started/install) development.

## Unique Use Cases - Notation Software

I've been dabbling with [Musescore Notation Software](https://musescore.org/en),
and as of right now things are working quite well. I did have to change my audio
I/O settings within Musescore to use ALSA (and I'm not with-it enough in the
Linux audio space to know why), but I was able to plug in a MIDI-keyboard for
input without issue once I did so.

Overall, I was quite surprised that it was a no-hassle configuration once I
sorted the audio I/O issue as I do find MIDI keyboard inputs (or external,
non-traditional input devices in general) to be a potential sticking point.

## Graphical Drivers

![solussytemconfig](/images/solus-systemconfig.png)


Even Nvidia installed without an issue. The system has a utility that seems to
be called "DoFlicky" that allows you to swap out your graphics drivers if you
have an appropriate card in the system. My settings are below (this machine was
built a LONG time ago), and installing the driver was a point-and-click +
restart experience (and, honestly, I don't even remember if the restart was
required). Kudos to the Solus devs there.

## Snaps

I've just installed the Bitwarden snap as it is not available in the software center.
The one quirk I've seen is that snap-installed things don't launch despite showing
up in the application menu. It's a bit odd, but I haven't sat down to troubleshoot.

Here's the error for reference:

```
$ bitwarden
cannot query current apparmor profile: Invalid argument
```

And the information on that snap for reference

```
$ snap info bitwarden
name:      bitwarden
summary:   A secure and free password manager for all of your devices.
publisher: 8bit Solutions LLC (bitwarden✓)
store-url: https://snapcraft.io/bitwarden
contact:   https://bitwarden.com
license:   unset
description: |
  Bitwarden, Inc., parent company of 8bit Solutions LLC, brings you Bitwarden.
  
  Bitwarden is the easiest and safest way to store all of your logins and passwords while
  conveniently keeping them synced between all of your devices.
  
  Password theft is a serious problem. The websites and apps that you use are under attack every
  day. Security breaches occur and your passwords are stolen. When you reuse the same passwords
  across apps and websites hackers can easily access your email, bank, and other important accounts.
  
  Security experts recommend that you use a different, randomly generated password for every account
  that you create. But how do you manage all those passwords? Bitwarden makes it easy for you to
  create, store, and access your passwords.
  
  Bitwarden stores all of your logins in an encrypted vault that syncs across all of your devices.
  Since it's fully encrypted before it ever leaves your device, only you have access to your data.
  Not even the team at Bitwarden can read your data, even if we wanted to. Your data is sealed with
  AES-256 bit encryption, salted hashing, and PBKDF2 SHA-256.
  
  Bitwarden is focused on open source software. The source code for Bitwarden is hosted on GitHub
  and everyone is free to review, audit, and contribute to the Bitwarden codebase.
commands:
  - bitwarden
snap-id:      Nvk8FZTYrAYFKXN74w5LtOrnOhE38fU8
tracking:     latest/stable
refresh-date: today at 09:21 CDT
channels:
  latest/stable:    1.25.1 2021-03-18 (44) 71MB -
  latest/candidate: ↑                           
  latest/beta:      ↑                           
  latest/edge:      ↑                           
installed:          1.25.1            (44) 71MB -
```

As I'm pressed for time, I'll haev to look into this another day.

## Summary

Overall, the experience is more than positive. If I had to install an operating
system on a machine for a family member (read: non-technical, no development
work, etc), I would have no qualms about installing Solus as of today. My
requirements are a bit more stringent
