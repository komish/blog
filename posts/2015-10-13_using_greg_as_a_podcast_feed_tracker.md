---
title: Using 'greg' as a Podcast Feed Tracker On Your Server
date: 2015-10-13
categories: [self-hosted]
tags: [Python, Servers]
description: Setup the 'greg' python utility to automatically download new podcast episodes.
aliases:
- /blog/using-greg-as-a-podcast-feed-tracker-on-your-server.html
---

I frequently listen to a few Linux/Tech podcasts on the week, but lack a solid centralized location in which to keep my downloaded files. Sure, I can simply use my primary laptop, but then what if I want to listen to these while on the gaming rig? 

Given that I have a home server setup with a simple RAID-1 array sharing my files out to my network using Samba, it only makes sense that I also store/share my podcasts in the same fashion. 

*[Greg](https://github.com/manolomartinez/greg)* is a utility written in python3 by Github user **[ManoloMartinez](https://github.com/manolomartinez/)** that essentially extends the functionality of *[feedparser](https://pypi.python.org/pypi/feedparser)* (another python utility) to allow you to track RSS feeds and easily download your favorite content. The Github README is beautifully written and very descriptive, and being that it is concise the primary configuration file fills in where the README falls short. 

### Preparing the OS ###
My Samba server is currently running CentOS 7; by default CentOS7 does **NOT** provide Python3 packages - we'll have to address this first and luckily EPEL comes to the rescue:

    [user@centos7]$ sudo yum install epel-release
    
Once we have EPEL installed, you can confirm that you have Python34 packages available to you:

	[user@centos7]$ sudo yum info python34
	(..truncated..)
	Available Packages
	Name        : python34
	Arch        : x86_64
	Version     : 3.4.3
	Release     : 2.el7
	Size        : 49 k
	Repo        : epel/x86_64
	Summary     : Version 3 of the Python programming language aka Python 3000
	URL         : http://www.python.org/
	License     : Python
	Description : Python 3 is a new version of the language that is incompatible with the 2.x
	            : line of releases. The language is mostly the same, but many details, especially
	            : how built-in objects like dictionaries and strings work, have changed
	            : considerably, and a lot of deprecated features have finally been removed.

This is all we'll need to get started, so lets get this installed and proceed:

	[user@centos7]$ sudo yum install python34

With this installed, we should have the necessary tools to install *greg*. For clarity's sake, we'll install it in a virtual environment. We'll also symlink your python3.4 binary to python3. Lets find out where python3.4 is installed:

	[user@centos7]$ which python3.4
	/usr/bin/python3.4
	
Go ahead and link a new python3 file to this one - this is purely for quality-of-life purposes:

	[user@centos7]$ ln -sf /usr/bin/python3.4 /usr/bin/python3

By default you may not have virtualenv installed - we'll assume you also don't have pip installed so we'll get that settled now.

	[user@centos7]$ easy_install pip

And then from here install virtualenv:

	[user@centos7]$ sudo pip install virtualenv

Lastly, confirm you have virtualenv-3.4 to use alongside your new python installation:

	[user@centos7]$ which virtualenv-3.4
	/usr/bin/virtualenv-3.4

### Installing the Software ###
From there, go ahead and create your virtual environment. We'll name ours 'greg-podcasts' and also specify the python3 interpretor (just in case):

	[user@centos7]$ virtualenv-3.4 -p $(which python3) greg-podcasts

From there, lets go ahead and activate the environment and perform our installation. We're going to install this as a normal user instead of root, so our pip install command will take this into account:

 	[user@centos7]$ source greg-podcasts/bin/activate
 	(greg-podcasts)[user@centos7]$ pip3 install --user user greg stagger
 	
 Once this completes, confirm that greg is installed -
 
 	  (greg-podcasts)[user@centos7]$ greg --help
 	  usage: greg [-h] [--configfile CONFIGFILE] [--datadirectory DATADIRECTORY]
 	  			{add,edit,info,list,sync,check,download,remove,retrieveglobalconf,rgc} ...
	
		positional arguments:
		  {add,edit,info,list,sync,check,download,remove,retrieveglobalconf,rgc}
		    add                 adds a new feed
		    edit                edits a feed
		    info                provides information about a feed
		    list                lists all feeds
		    sync                syncs feed(s)
		    check               checks feed(s)
		    download            downloads particular issues of a feed
		    remove              removes feed(s)
		    retrieveglobalconf (rgc)
		                        retrieves the path to the global config file
		
		optional arguments:
		  -h, --help            show this help message and exit
		  --configfile CONFIGFILE, -cf CONFIGFILE
		                        specifies the config file that greg should use
		  --datadirectory DATADIRECTORY, -dtd DATADIRECTORY
		                        specifies the directory where greg keeps its data
		                        
### Configuring the Software ###
                   
As mentioned, the [Github README](https://github.com/manolomartinez/greg) explains the utility very well so further reading should absolutely take place using this file. For now, let's set up a simple feed, and a script to check daily for updates to this feed.

The [TechSNAP Podcast](http://feeds2.feedburner.com/techsnapmp3) is a one-stop-shop for interesting news items happening in the Linux and Tech world. We'll add this podcast to our feed watcher and get this checked daily for new episodes. First thing's first, lets get a configuration file in place. 

The Github README file dictates that we can create a custom configuration file based on the global configuration file to perform edits specific to our situation - the defaults actually work fairly well, but we'll create a local file anyway:

	(greg-podcasts)[user@centos7]$ mkdir -p ~/.config/greg/
	(greg-podcasts)[user@centos7]$ cp $(greg retrieveglobalconf) ~/.config/greg/greg.conf
	
We'll leave this as is for now, but this file will contain options such as how many podcasts you want to download upon adding a new feed, where you want to store them, or adjusting the mimetype - it's heavily commented and very clear in what it is trying to achieve. Take a look if those options seem relevant to you.

By default, however, the software will download audio-only content, and 1 (the latest) podcast on initial sync. These are sensible defaults, so no real need for change. By default, this will create a directory ~/Podcasts and store your files there - for my case I've symlinked this to my RAID-1 and adjusted permissions so that my user can write there without issue.

Lets go ahead and set up a feed, we'll use TechSNAP's feed - **http://feeds.feedburner.com/techsnapmp3** for this example:

	(greg-podcasts)[user@centos7]$ greg add TechSNAP http://feeds.feedburner.com/techsnapmp3
	
Notice that we add a label "TechSNAP" to reference our feed. We can then confirm this was added and see the current status (since we haven't executed a sync yet, there will be little information here *except* the fact that we've added a feed:

	(greg-podcasts)[user@centos7]$ greg info 
	TechSNAP
	--------
    url: http://feeds.feedburner.com/techsnapmp3
    
Now that we've added our feed, we can go ahead and execute a sync - this will have *greg* go and download the latest episode and place it in **~/Podcasts/** for you. 

	(greg-podcasts)[user@centos7]$ greg sync

You should see some output regarding the episode name and the like - lets run the info command again:

	(greg-podcasts)[user@centos7]$ greg info
	TechSNAP
	--------
    url: http://feeds.feedburner.com/techsnapmp3
    Next sync will download from: 09 Oct 2015 02:32:14.
    
You'll notice now we have a date in which this will check for new episodes. Note that this isn't "when greg will check again", but rather just a marker indicating greg will not download any episodes with a release date PRIOR to the stated value. This can be adjusted if you'd like, check out the "*greg edit*" command with the **-d** flag.

### Automate the download ###

Now that we have a feed that we're monitoring, we have to set up greg to automatically check the feed periodically, and perform downloads when new content is found. We can do this with **cron**, but since we're using a Virtualenv we need to gather some information regarding our path first. While still in your Virtualenv, retrieve your environment's path:

	(greg-podcasts)[user@centos7]$ echo $PATH
	
Your output should be similar to the following:

	/home/user/virtualenvs/greg-podcasts/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/user/.local/bin:/home/user/bin
	
Lets create a script that uses this information as is (you should be able to copy paste the below command):

	(greg-podcasts)[user@centos7]$ cat >>greg-cron.sh<<EOF
	#!/usr/bin/env bash
	PATH="$PATH"
	
	$(which greg) sync
	EOF

Check you file, it should look something similar to the following:

	(greg-podcasts)[user@centos7]$ cat greg-cron.sh
	#!/usr/bin/env bash
	PATH=/home/user/virtualenvs/greg-podcasts/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/user/.local/bin:/home/user/bin
	
	/usr/bin/greg sync
	
Make this script executable:

	(greg-podcasts)[user@centos7]$ chmod +x greg-cron.sh
	
Lastly, add your script to your crontab as you see fit! I run mine every day at 12:30PM. Happy Listening!
