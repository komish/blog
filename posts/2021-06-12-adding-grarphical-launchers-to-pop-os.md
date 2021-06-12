---
title: "Adding a Graphical Launcher to Pop!_OS (or Gnome)"
publishDate: 2021-06-12
categories: [Notes]
tags: [pop-os, system76, factorio, gnome-shell]
description: "Creating desktop launchers in desktop environments based on Gnome Shell."
---

I installed [Pop!_OS by System76](https://pop.system76.com/) on my Desktop
machine and have been taking the system for a spin. One of the first things
I do on my desktop machine, regardless of the operator system it is running,
is install [Factorio](https://www.factorio.com/). The reality is the game is
quite well optimized as far as I can tell, and hasn't had an issue running
on every machine that I've tried. In fairness, I've not tried my laptops with
Celeron chips.

I install the game from the website directly, and I end up with a runnable binary
that I can just execute on a linux machine. For quality of life purposes, I always
try to get the binary integrated into the launcher or "menu" system. In Gnome, which
is the desktop environment that underpins Pop!_OS, I just want to integrate it into
the launcher that shows up when I press the meta key.

Folks that are familiar with Gnome probably know how to accomplish that, but I tend
to avoid Gnome these days, and it has been too long since I've had to do this. With that
in mind, this is note on the subject.

---

It's actually quite simple to accomplish. As a frame of reference, I'll assume
that the version of `gnome-shell` is important, and so I have this version here:

```shell
$ gnome-shell --version
GNOME Shell 3.36.7
```

With that in mind, all I really needed to do was create a Desktop launcher
in the `.local/share/applications` directory in my home folder.

```shell
$ cat ~/.local/share/applications/factorio.desktop 
[Desktop Entry]
Encoding=UTF-8
Name=Factorio
Exec=/home/komish/Games/factorio/bin/x64/factorio
Icon=/home/komish/Games/factorio/data/core/graphics/factorio.png
Type=Application
Categories=Game;
```

Desktop Files, such as this one, are written in a standardized format. From what
I can tell, it appears to be based on the FreeDesktop's Desktop Menu
Specification. From my testing, this file cannot be a symlink and must be an
actual file.

I tried to create a symlink in this location to keep this Desktop
file in a centralized location that is either (a) easy to backup, or (b) easy to
commit to source control; the Gnome desktop environment was not having that.

It's also worth noting that I've only installed Factorio local to my user (which
here just means that the binary is only accessible to my user). With this in
mind, my chosen install location for the desktop file only applies to my logged
in context. That's an acceptable trade off for me.

I keep these files relatively sparse. If you want to read about this more in
depth, or add much more metadata into the desktop file, the [Gnome Desktop
Documentation on Desktop
Files](https://developer.gnome.org/integration-guide/stable/desktop-files.html.en)
should have you covered.
