---
title: Disk Enumeration Behavior with OpenStack Nova and Libvirt+KVM
date: 2018-01-06
categories: [OpenStack]
tags: [openstack, nova, libvirt, kvm, cinder, linux]
description: Observing interesting behaviors in attaching volumes to resized instances.
aliases:
- /blog/disk-enumeration-behavior-with-openstack-nova-libvirt-kvm.html
---

I've run into some form of this issue error message when attempting to attach disks to instance running in an OpenStack cluster using Libvirt+KVM.

```
source: /var/log/nova/nova-compute.log
2018-01-06 22:18:38.049 8884 ERROR oslo_messaging.rpc.server [req-6981a024-faf2-4c94-91c4-4b0357a967c6 809d54e610184b26b41ac637a4314801 98a97dc5b2b74455add34ed624bf4b6a - default default] Exception during message handling: libvirtError: Requested operation is not valid: target vdc already exists
```

Usually, this will take place with very little context - a user will try to attach a block and will get the standard response from their client of choice indicating that the request has gone through. But the disk will never attach with absolutely no client-side error message. The disk simply shows to be 'available' for seeminly no reason at all, and the above error message will be in nova-compute.log.

So what gives?

From what I've seen, the source of the issue seems to be the enumeration logic done by nova code to determine how to enumerate an attached disk based on the disks that are presented already - and something tells me it's partially due to the bug(?) which prevents an end-user from specifying which device a disk will become on attach in KVM-based hypervisors. Disclaimer: I've only taken a cursory look over the code to determine how to reproduce this. In most cases I've seen, this issue will appear when an instance has been resized to include an ephemeral or a swap disk while a cinder block is attached, and then the cinder block is detached. After that block is detached, re-attaching (or attaching a new block) will trigger the Exception.

Reproducing this is fairly straightforward. In this case I've done so in a lab deployed using [openstack-ansible](https://docs.openstack.org/openstack-ansible/latest/) putting me on the Pike release of OpenStack.

```
(lab01)# cat /etc/openstack-release 
# Ansible managed

DISTRIB_ID="OSA"
DISTRIB_RELEASE="17.0.0.0b1"
DISTRIB_CODENAME="Pike"
DISTRIB_DESCRIPTION="OpenStack-Ansible"
```

I have two flavors defined which are nearly identical - the only difference being a swap disk:

```
(lab01)# nova flavor-show small-with-swap
+----------------------------+-----------------+
| Property                   | Value           |
+----------------------------+-----------------+
| OS-FLV-DISABLED:disabled   | False           |
| OS-FLV-EXT-DATA:ephemeral  | 0               |
| disk                       | 1               |
| extra_specs                | {}              |
| id                         | 203             |
| name                       | small-with-swap |
| os-flavor-access:is_public | True            |
| ram                        | 512             |
| rxtx_factor                | 1.0             |
| swap                       | 1               |
| vcpus                      | 1               |
+----------------------------+-----------------+
(lab01)# nova flavor-show small-no-swap 
+----------------------------+---------------+
| Property                   | Value         |
+----------------------------+---------------+
| OS-FLV-DISABLED:disabled   | False         |
| OS-FLV-EXT-DATA:ephemeral  | 0             |
| disk                       | 1             |
| extra_specs                | {}            |
| id                         | 204           |
| name                       | small-no-swap |
| os-flavor-access:is_public | True          |
| ram                        | 512           |
| rxtx_factor                | 1.0           |
| swap                       |               |
| vcpus                      | 1             |
+----------------------------+---------------+
```

For starters, I'll build an instance using the flavor with no swap defined. This should net us a single disk for this instance - for our case that will be `/dev/vda`. We'll attach a disk to this instance placing it at `/dev/vdb`.

```
(lab01)# nova list
+--------------------------------------+------------+--------+------------+-------------+-----------------------+
| ID                                   | Name       | Status | Task State | Power State | Networks              |
+--------------------------------------+------------+--------+------------+-------------+-----------------------+
| 0ac40227-597c-48d7-8379-9320beb7d3bd | instance01 | ACTIVE | -          | Running     | public=172.29.249.119 |
+--------------------------------------+------------+--------+------------+-------------+-----------------------+

(lab01)# nova show 0ac40227-597c-48d7-8379-9320beb7d3bd  | egrep "^\| (flavor|name|id)"
| flavor:disk                          | 1                                                                                |
| flavor:ephemeral                     | 0                                                                                |
| flavor:extra_specs                   | {}                                                                               |
| flavor:original_name                 | small-no-swap                                                                    |
| flavor:ram                           | 512                                                                              |
| flavor:swap                          | 0                                                                                |
| flavor:vcpus                         | 1                                                                                |
| id                                   | 0ac40227-597c-48d7-8379-9320beb7d3bd                                             |
| name                                 | instance01                                                                       |

(lab01)# nova volume-attach 0ac40227-597c-48d7-8379-9320beb7d3bd a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc
+----------+--------------------------------------+
| Property | Value                                |
+----------+--------------------------------------+
| device   | /dev/vdb                             |
| id       | a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc |
| serverId | 0ac40227-597c-48d7-8379-9320beb7d3bd |
| volumeId | a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc |
+----------+--------------------------------------+

(lab01)# cinder list
+--------------------------------------+--------+---------+------+-------------+----------+--------------------------------------+
| ID                                   | Status | Name    | Size | Volume Type | Bootable | Attached to                          |
+--------------------------------------+--------+---------+------+-------------+----------+--------------------------------------+
| a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc | in-use | volume1 | 1    | -           | false    | 0ac40227-597c-48d7-8379-9320beb7d3bd |
+--------------------------------------+--------+---------+------+-------------+----------+--------------------------------------+
```

We can see symptoms in the domain definition as well, so it's worth noting down that we see target devices`vda` and `vdb` at this point.

```
(lab01)# virsh dumpxml instance-0000000a
(...)
   <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' discard='ignore'/>
      <source file='/var/lib/nova/instances/0ac40227-597c-48d7-8379-9320beb7d3bd/disk'/>
      <backingStore type='file' index='1'>
        <format type='raw'/>
        <source file='/var/lib/nova/instances/_base/ba1c7a54010d83608e08b5c2e9a9f1562d608169'/>
        <backingStore/>
      </backingStore>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </disk>
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='/dev/sda'/>
      <backingStore/>
      <target dev='vdb' bus='virtio'/>
      <serial>a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc</serial>
      <alias name='virtio-disk1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
(...)
```

So at this point we'll initiate the resize action to change our instance to gain a swap disk.

```
(lab01)# nova resize instance01 small-with-swap
(lab01)# nova list
+--------------------------------------+------------+--------+---------------+-------------+-----------------------+
| ID                                   | Name       | Status | Task State    | Power State | Networks              |
+--------------------------------------+------------+--------+---------------+-------------+-----------------------+
| 0ac40227-597c-48d7-8379-9320beb7d3bd | instance01 | RESIZE | resize_finish | Running     | public=172.29.249.119 |
+--------------------------------------+------------+--------+---------------+-------------+-----------------------+

(lab01)# nova resize-confirm instance01
(lab01)# nova list
+--------------------------------------+------------+--------+------------+-------------+-----------------------+
| ID                                   | Name       | Status | Task State | Power State | Networks              |
+--------------------------------------+------------+--------+------------+-------------+-----------------------+
| 0ac40227-597c-48d7-8379-9320beb7d3bd | instance01 | ACTIVE | -          | Running     | public=172.29.249.119 |
+--------------------------------------+------------+--------+------------+-------------+-----------------------+
```

And once again verifying that we've gained a target dev `vdc` now as our swap disk:

```
(lab01)# virsh dumpxml instance-0000000a 
(...)
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' discard='ignore'/>
      <source file='/var/lib/nova/instances/0ac40227-597c-48d7-8379-9320beb7d3bd/disk'/>
      <backingStore type='file' index='1'>
        <format type='raw'/>
        <source file='/var/lib/nova/instances/_base/ba1c7a54010d83608e08b5c2e9a9f1562d608169'/>
        <backingStore/>
      </backingStore>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </disk>
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='/dev/sda'/>
      <backingStore/>
      <target dev='vdb' bus='virtio'/>
      <serial>a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc</serial>
      <alias name='virtio-disk1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </disk>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' discard='ignore'/>
      <source file='/var/lib/nova/instances/0ac40227-597c-48d7-8379-9320beb7d3bd/disk.swap'/>
      <backingStore type='file' index='1'>
        <format type='raw'/>
        <source file='/var/lib/nova/instances/_base/swap_1'/>
        <backingStore/>
      </backingStore>
      <target dev='vdc' bus='virtio'/>
      <alias name='virtio-disk2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
(...)
```

So now let's say we need to detach and re-attach our volume (or... even attach a new volume - whatever your use case might be):

```
(lab01)# nova volume-detach 0ac40227-597c-48d7-8379-9320beb7d3bd a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc
(lab01)# cinder list
+--------------------------------------+-----------+---------+------+-------------+----------+-------------+
| ID                                   | Status    | Name    | Size | Volume Type | Bootable | Attached to |
+--------------------------------------+-----------+---------+------+-------------+----------+-------------+
| a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc | available | volume1 | 1    | -           | false    |             |
+--------------------------------------+-----------+---------+------+-------------+----------+-------------+

(lab01)# nova volume-detach 0ac40227-597c-48d7-8379-9320beb7d3bd a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc
(lab01)# cinder list
+--------------------------------------+-----------+---------+------+-------------+----------+-------------+
| ID                                   | Status    | Name    | Size | Volume Type | Bootable | Attached to |
+--------------------------------------+-----------+---------+------+-------------+----------+-------------+
| a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc | available | volume1 | 1    | -           | false    |             |
+--------------------------------------+-----------+---------+------+-------------+----------+-------------+
```

Your volume will fail to re-attach throwing the error mentioned earlier in nova-compute.log. Checking the domain confirms the reason, where we see a `vda` and a `vdc` device.

```
(lab01)# virsh dumpxml instance-0000000a | grep "target dev='vd"
      <target dev='vda' bus='virtio'/>
      <target dev='vdc' bus='virtio'/>
```

You will need to hard reboot your instance (or stop+start) as a soft reboot does not initiate a recreation of the domain and as such the devices will not change. Once you've initiated the reboot, you'll notice that your devices have changed order.

```
(lab01)# virsh dumpxml instance-0000000a | grep "target dev='vd"
      <target dev='vda' bus='virtio'/>
      <target dev='vdb' bus='virtio'/>
```

Attaching your volume should go through without a hitch.

```
(lab01)# nova volume-attach 0ac40227-597c-48d7-8379-9320beb7d3bd a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc
+----------+--------------------------------------+
| Property | Value                                |
+----------+--------------------------------------+
| device   | /dev/vdc                             |
| id       | a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc |
| serverId | 0ac40227-597c-48d7-8379-9320beb7d3bd |
| volumeId | a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc |
+----------+--------------------------------------+

(lab01)# cinder list
+--------------------------------------+--------+---------+------+-------------+----------+--------------------------------------+
| ID                                   | Status | Name    | Size | Volume Type | Bootable | Attached to                          |
+--------------------------------------+--------+---------+------+-------------+----------+--------------------------------------+
| a54facb5-8b1e-4370-9d0b-e7b6ca6f7adc | in-use | volume1 | 1    | -           | false    | 0ac40227-597c-48d7-8379-9320beb7d3bd |
+--------------------------------------+--------+---------+------+-------------+----------+--------------------------------------+

(lab01)# virsh dumpxml instance-0000000a | grep "target dev='vd"
      <target dev='vda' bus='virtio'/>
      <target dev='vdb' bus='virtio'/>
      <target dev='vdc' bus='virtio'/>
```

In short-term context (i.e. when you might be adjusting volumes on an instance) this kind of issue may not be difficult to track down, but if you happen to detach on one day and attach a new volume several days or weeks later - it can easily be overlooked.

So why does this happen? My theory is that nova code is not able to determine the letters associated with devices on an instance (which goes back to the bug related to being unable to specify your device on attach). What it can likely determine is the number of devices attached - and I assume it's logically determing the next 'letter' to present based on the tiered count of disks already attached to a guest (root disk > local disks such as swap/ephemeral > cinder attached volumes). With this tiering in mind, it makes logical sense that the next available label for a cinder volume should come after these, and the conflict arises when our swap disk is attached in a LATER position than expected. Again - all theories, as I have no spent the time to review the code.

So is this a bug? I would think it isn't - ultimately it's handling a situation as cleanly as possible given the constraints of the system (at least as I understand them). There may not be a good way to determine the disk labeling that exists currently without reading in the domain configuration - and as I understand it nova-compute tends to avoid READING this configuration as it can be manually modified and therefore cause inconsistencies with nova database records.

Resolving this is a bit inconvenient as it seems to require a hard reboot - and it *could* cause issues with mount points that could be detrimental to hosted applications (though, mounting blocks should be done with UUIDs, labels, or similar). And as it appears to be a silent failure, it is almost guaranteed to trigger a discussion or a ticket for your operations organization. Overall, it's a fairly minimal inconvenience and is more interesting than problematic.
