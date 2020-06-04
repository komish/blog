---
title: Thin Provisioning fails with LVM-backed LXC containers with LXD
date: 2016-08-14
categories: [System Administration]
tags: [lxc, lxd, containers, docker]
description: Enabling LVM-backed containers with LXD.
aliases:
- /blog/enable-lvm-backing-with-thin-provisioning-in-lxd.html
---

Having a freshly kicked install of Ubuntu 16.04 Server amd64, one of the pre-configured services you'll find installed is the **lxc** containervisor, ready to spin up LXC containers. I've preconfigured a 1.6TB partition into a volume group to be used as an LXC container backing store, but by default LXD will configure your containers to utilize flat files on the filesystem containing `/var/lib/lxc/`. 

I'll skip through the pieces that require you to initialize LXD, configure a network bridge, or add remote image stores as there are plenty of walkthroughs online for such a process. After those pieces are in place, you should be able to execute a command similar to the following to simply start a container (subbing out your image, backing store, and container name as you see fit):

```
lxc launch ubuntu:628c432840e1 ubuntu-1404-amd64
```

This will create a container with the local filesystem used as the backing store. My root filesystem is a measly 60gb in size, so I'm opting to use LVM. To trigger LVM as the backing store, delete your previously created container and run the following at the command line:

```
lxc config set storage.lvm_vg_name "VG_NAME_HERE"
```

Run the same launch command and you'll be met with a rather vague message indicating a failure to perform said launch action:

```
# lxc launch ubuntu:628c432840e1 ubuntu-1404-amd64
Creating ubuntu-1404-amd64
error: Error Creating LVM LV for new image: Could not create thin LV named 628c432840e1aedc44006d3c6f7ace79d50753d2267b159289cd2e7490f2348f
```

Of course, that random string does indicate a logical volume identified that failed to be created. Given the lacking output as a result of the launch command, I needed to hunt through logs for relevant information - defaulting to the lxd logs found in `/var/lib/lxd/lxd.log`. I found the following relevant piece:

```
t=2016-08-14T21:49:40-0500 lvl=eror msg="Could not create LV" driver=storage/lvm lvname=628c432840e1aedc44006d3c6f7ace79d50753d2267b159289cd2e7490f2348f output="  /usr/sbin/thin_check: execvp failed: No such file or directory\n  Check of
pool container/LXDPool failed (status:2). Manual repair required!\n  Aborting. Failed to locally activate thin pool container/LXDPool.\n"
t=2016-08-14T21:49:40-0500 lvl=eror msg=LVMCreateThinLV driver=storage/lvm err="Could not create thin LV named 628c432840e1aedc44006d3c6f7ace79d50753d2267b159289cd2e7490f2348f"
```

From this output, I determined that the executed command `/usr/sbin/thin_check` was the missing piece and this file didn't exist on my filesystem. A quick google search led me to to install the following package which is not installed by default:

```
apt-get install thin-provisioning-tools -y 
```

After which, I was able to boot my container and verify the logical volume snapshot based on the logical volume created by `lxd`:

```
# lvs
  LV                                                               VG        Attr       LSize  Pool    Origin                                                           Data%  Meta%  Move Log Cpy%Sync Convert
  628c432840e1aedc44006d3c6f7ace79d50753d2267b159289cd2e7490f2348f container Vwi-a-tz-- 10.00g LXDPool                                                                  8.70
  LXDPool                                                          container twi---tz--  1.63t                                                                          0.05   0.36
  test1                                                            container Vwi-aotz-- 10.00g LXDPool 628c432840e1aedc44006d3c6f7ace79d50753d2267b159289cd2e7490f2348f 8.70
```

Ideally moving forward I will disable thin provisioning if possible and simply use a unique logical volume per container, but for the time being this is a solid setup.






