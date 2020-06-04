---
title: Retrofitting "Kubernetes the Hard Way" for the Rackspace Cloud
date: 2019-03-10
categories: [Kubernetes]
tags: [kubernetes, k8s, containers, learning]
description: Some quick insights into using the Rackspace Cloud to run through 'Kubernetes the Hard Way'
aliases: 
- /blog/retrofitting-kthw-for-the-rackspace-cloud.html
---

Kelsey Hightower's [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) is an incredible resource for any Engineer taking their first steps into understanding Kubernetes deployment fundamentals. Maintaining a resource as detailed as this walkthrough can be difficult, and it can be even more difficult to maintain it across the various infrastructure platforms available today. To maintain a high level of quality out of the guide, the choice was made to focus on the Google Cloud Platform--but it doesn't take much effort to retrofit the steps to your own infrastructure provider of choice.

What follows is a collection of notes and considerations that you will need to think about when running through [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) but using the Rackspace Cloud as your infrastructure of choice. Most things are fairly straightforward to translate, but there are a few implicit behaviors that are not identified in the walkthrough that can cause some confusion.

## How to Use This Guide

The sections will be organized identically to the document structure of the "Kubernetes The Hard Way" repository.

This guide is **not** a re-write of Kubernetes the Hard Way. You should not expect this document to be maintained or updated to keep in line with the latest branch of the repository. Treat this as a companion guide. I would recommend doing an entire read of the repository section followed by a read of the same section in this document to grasp the caveats.

As the repository is updated, this guide will likely fall behind--and that should be acceptable. The caveats will likely remain similar as the repository changes. 

The repository release that is relevant at the time of this posting is at Kubernetes version [1.12](https://github.com/kelseyhightower/kubernetes-the-hard-way/tree/bf2850974e19c118d04fdc0809ce2ae8a0026a27). This is a direct link to the latest commit when this was executed.

So with that, let us begin.

## [01-Prerequisites.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/01-prerequisites.md)

The prerequisites discussed are the configuration of the `gcloud` utility used to interface with the GCP platform, and the explanation of the need for a terminal multiplexor such as `tmux` to blast commands to multiple windows at once. Terminal multiplexing can be done however you want and there are no functional differences to executing this in any other infrastructure.

As we're not using GCP, obviously `gcloud` isn't necessary here. That said, throughout the walkthrough there are certain `gcloud` commands that are used to pull information about our compute resources which are then used for templating. Generally, we'll do those commands in a different way that also doesn't require interaction with the infrastructure provider. It will be a bit more manual, but it will get the job done.

The configuration of `gcloud` also has you define your resource region. You can build in any region in the Rackspace Cloud--the key is that all of your resources are in the same region. 

If a commandline utility to interact with the infrastructure is interesting to you, check out [rack](https://developer.rackspace.com/docs/rack-cli/). It is not necessary to configure and use `rack` CLI for the caveats noted here.

## [02-client-tools.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/02-client-tools.md)

At face value, this document is also infrastructure-vendor agnostic. With that said, I'll throw in a personal caveat to how this document is used. 

Ultimately, this document covers client tooling installation with the assumption that you want to do this lab on your workstation. As I worked on this project through a few devices, it made sense to have a separate "workstation" device that could be accessed from multiple locations. You will build 6 instances (3 controllers, 3 workers) for this guide - but I used a 7th instance as my workstation and did all of my client installation work there. This is completely optional, but the next lab describes the caveats of building your compute resources. It might make sense to start with [03-compute-resources.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/03-compute-resources.md) and then circle back to this document to install your clients.

Aside from that, there is not much to note here.

## [03-compute-resources.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/03-compute-resources.md)

I provisioned all of my resources via the [Rackspace Control Panel](https://login.rackspace.com). That said, I have created a heat template that should provision all of these resources for you using [Rackspace Cloud Orchestration](https://developer.rackspace.com/docs/user-guides/orchestration/). That template can be found [here](https://github.com/Komish/heat-templates/blob/master/k8s-the-hard-way-rax-cloud/).

Here's a quick summary of the resources that are required throughout this lab:

* 1 Cloud Network
* 1 Cloud Load Balancer
* 6 Cloud Servers (7 if you intend to use one as a "workstation")

#### Cloud Network

The walkthrough has you start by creating your **Virtual Private Cloud Network**. Provisioning the network in the Rackspace Cloud is straightforward and there are no caveats that are worth noting. You can use the same range of **10.240.0.0/24** that this lab indicates but this isn't required. You will just need to be consistent with your choice throughout the remaining labs.

![raxcloud-network-create](/images/kthw-raxcloud-network-create.png)

#### Firewall Rules

In the Rackspace Cloud - no default security groups are put in place and we will assume that none are in use for your lab. As we are just now creating this network, it stands to reason that existing security groups on your account will likely not apply to your newly created Cloud Network. If you should have Security Groups on your account, make sure that they are not applying to your instances in use for this lab.

#### Kubernetes Public IP Address

This section provisions a Kubernetes Public IP Address from the GCP infrastructure. For the Rackspace Cloud, building a Rackspace Cloud Loadbalancer will accomplish the same task. This will be configured to listen on 6443 to be consistent with the lab material. Also have the protocol set to HTTPS. You don't need to configure nodes for this yet as we don't have compute resources provisioned at this point.

![raxcloud-lb-provision](/images/kthw-raxcloud-lb-provision.png)

#### Kubernetes Controllers

We'll provision these nodes with Ubuntu 18.04 exactly as is done in the tutorial. 

Ubuntu 18.04 LTS (Bionic Beaver) (PVHVM)

![raxcloud-1804-image](/images/kthw-raxcloud-1804-image.png)

I used 2GB General Purpose VMs as I knew this would be a short-lived lab. You don't need a large amount of space to complete the lab, but you can scale up to whatever flavor suits you best. 

2 GB General Purpose v1

![raxcloud-2gb-flavor](/images/kthw-raxcloud-2gb-flavor.png)

Remember that each of these servers need to be attached to the Cloud Network you provisioned earlier in the tutorial. At server creation, drop down the "Advanced Options" tab and add your network to this instance at boot time. 

![raxcloud-server-adv-options](/images/kthw-raxcloud-server-adv-options.png)

I would also recommend having the provisioning process install your SSH Public Key. If you don't have one, create one before you start deploying instances. If you decide to utilize a workstation instance as mentioned earlier - place the relevant private key there for ease of access.

#### Kubernetes Workers

This is mostly the same as provisioning the Kubernetes Controllers. The key difference here is a reference to the pod cidr - which is injected as server metadata in the tutorial. We won't be doing anything with this here, but you will need to handle this later when working in the instances. Make note that the tutorial deploys 3 separate ranges **10.200.[012].0/24**, one for each worker node that is provisioned. This network *does* differ from the private network we provisioned earlier and there is no correlation between the two. In effect, it will be a local-only network. 

#### Configure SSH Access

This is fairly straightforward here and not specific to any infrastructure provider. Earlier you should have provisioned instances with keys, but if you did not then I would recommend provisioning a key and deploying it to all 6 nodes. If you're using a workstation VM as suggested, put your private key there and make sure that it can reach all 6 nodes. 

#### Additional Notes

If you intended to create a workstation VM, you can create it identically to any of the worker or controller nodes you've previously provisioned. 

There will be references to the private and public IP addresses of each node later in the tutorial. I would advise SSHing into every node that we've provisioned and creating environment variables for the node's respective public and private IP address. I placed these in `~/.bash_aliases`. Something like this should suffice, as `eth0` and `eth2` are the most likely interfaces where your relevant networks will reside. If this isn't the case in your image, make the necessary adjustments.

```shell
{
    EXT=$(ifconfig eth0 | awk '/inet\ / { print $2 }')
    INT=$(ifconfig eth2 | awk '/inet\ / { print $2 }')

    echo 'export EXTERNAL_IP='"${EXT}" >> ~/.bash_aliases
    echo 'export INTERNAL_IP='"${INT}" >> ~/.bash_aliases
}
```

I would also recommend adding the `KUBERNETES_PUBLIC_ADDRESS` environment variable exported via `~/.bash_aliases` on every node, including your workstation. Set this to the IP address of your Cloud Loadbalancer:

```shell
echo 'export KUBERNETES_PUBLIC_ADDRESS="clb.ip.goes.here"' >> ~/.bash_aliases
```

On your workstation (or workstation instance), I would recommend a few /etc/hosts entries as well. I structured mine to look something like this (please change the names of the nodes to match their short hostnames (public|private).`hostname -s`):

```shell
a.b.c.1 public.ctrl-1
a.b.c.2 public.ctrl-2
a.b.c.3 public.ctrl-3
a.b.c.4 public.worker-1
a.b.c.5 public.worker-2
a.b.c.6 public.worker-3

10.240.0.3 private.ctrl-1 ctrl-1
10.240.0.4 private.ctrl-2 ctrl-2
10.240.0.5 private.ctrl-3 ctrl-3
10.240.0.6 private.worker-1 worker-1
10.240.0.7 private.worker-2 worker-2
10.240.0.8 private.worker-3 worker-3
```

Finally, I recommend adding /etc/hosts entries to all of your controllers and workers that gives them easy resolution to the other nodes via their private network address. Something like this should suffice:

```
10.240.0.3 ctrl-1
10.240.0.4 ctrl-2
10.240.0.5 ctrl-3
10.240.0.6 worker-1
10.240.0.8 worker-3
10.240.0.7 worker-2
```

Substitute your assigned private addresses as necessary.

## [04-certificate-authority.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/04-certificate-authority.md)

**Remember**: If you decided to provision a workstation instance instead of using your local workstation for this lab work, then you will likely need to return to [02-client-tools.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/02-client-tools.md) to install clients on this instance.

This lab has a lot of sections for specific client certificates that are generated. We'll make references to only those which require specific alterations to the approach in which something is generated.

In general, a lot of the client certificates that are generated make references to your instance names (matching `hostname -s`). Be cognizant of what is being done in a given for loop and swap out those names to make them relevant for your environment. 

#### The Kubelet Client Certificates

The very first set of client certificates are generated for your workers, and includes a tidbit to poll *gcloud* for server metadata--that looks something like this:

```shell
EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')
```

Previously we had prepared our workstation with `/etc/hosts` entries mapping these back, so we can use that now to fill in these values for this `for` loop. Adjusting the variable section to look something like should work:

```shell
EXTERNAL_IP=$(dig +short public.${instance})
INTERNAL_IP=$(dig +short private.${instance})

# alternative if you find yourself without `dig` installed
EXTERNAL_IP=$(awk '/public.'${instance}'/ { print $1 }' /etc/hosts)
INTERNAL_IP=$(awk '/private.'${instance}'/ { print $1 }' /etc/hosts)
```

You end up with something that looks like this, assuming you've substituted your instance names in the proper place:

```shell
for instance in worker-1 worker-2 worker-3; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

# this is what we changed
EXTERNAL_IP=$(dig +short public.${instance})
INTERNAL_IP=$(dig +short private.${instance})

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
```

#### The Kubernetes API Server Certificate

The very first piece of this requires setting your `KUBERNETES_PUBLIC_ADDRESS` variable which we added to our `.bash_aliases` file earlier in this guide. Confirm this is the case:

```shell
echo $KUBERNETES_PUBLIC_ADDRESS
```

You'll see that this value is used as a value to the `cfssl` command's `-hostname` flag. 

```shell
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
```

You will need to change this flag further, as it makes references to IP addresses that should map back to your controllers:

```
10.240.0.10,10.240.0.11,10.240.0.12
```

There's a good chance that the IP addresses your controllers received during provision differ and so you will need to adjust these values to be correct. You can pull them from your `/etc/hosts` file or alternatively use the following to dynamically pull them from the same file with `dig`.

```shell
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,$(dig +short private.ctrl-1),$(dig +short private.ctrl-2),$(dig +short private.ctrl-3),${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
```

If you want to properly confirm this resolves as you expect, throw an `echo` in the front of the command and you should see all three IP addresses render properly.

#### Distribute the Client and Server Certificates

The final distribtion of keys makes a reference to *gcloud* which naturally doesn't apply for us - but the syntax is identical to `scp` so you should imply be able to remove the *gcloud* bits (and substitute your instance names where relevant).

```shell
# workers
for instance in worker-1 worker-2 worker-3; do
  scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

# controllers
for instance in ctrl-1 ctrl-2 ctrl-3; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done
```

## [05-kubernetes-configuration-files.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/05-kubernetes-configuration-files.md)

This section makes a lot of references to the worker nodes, so make sure you're substituting your hostnames every time you see a reference to your instances as we won't be breaking down each section if the only variation it contains is this piece.

It also starts off right away with a reference to `KUBERNETES_PUBLIC_ADDRESS` which should be exported as a part of your `~/.bash_aliases` file and should map back to the IP address associated with your Cloud Loadbalancer. Make sure this is set (`echo $KUBERNETES_PUBLIC_ADDRESS` ) before proceeding.

#### Distribute the Kubernetes Configuration Files

As with the previous section, this section makes a reference to *gcloud* to SCP configurations to destination hosts. Simply remove the `gcloud compute` piece and this should translate to `scp` on your machine. 

## [06-data-encryption-keys.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/06-data-encryption-keys.md)

#### The Encryption Config File

As previously, a *gcloud* is used to copy the encryption keys to target hosts. Remove the gcloud pieces (`gcloud compute`) to simply utilize `scp` on your machine.

## [07-bootstrapping-etcd.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/07-bootstrapping-etcd.md)

At this point, you'll begin to use a utility like `tmux` to run commands across a subset of nodes. You will likely start to take advantage of local environment variables on each node. Don't hesitate to double check your variables (`echo $VARIABLE`) before running a command to make sure that the variable is actually set in your environment.

#### Configure the etcd Server

This section makes an API call to the gcloud compute metadata services to set the internal IP address of your instances as a variable. We set this variable previously, so you can simply check that it exists or set it now.

```shell
test ! -z ${INTERNAL_IP} || INTERNAL_IP=4(ifconfig eth2 | awk '/inet\ / { print $2 }')
```

You should be able to run this across all controllers.

You'll immediately put this value to good use at the creation of the systemd etcd.service file, however this requires further modification. The unit file contains a definition of the initial controllers which is hard coded to use the same naming convention as the rest of the document. It also makes reference to the private IP addresses of those controllers. The cleanest approach is to manually change the values here in a text editor, and then copy the entire blob into your broadcasting terminal. Here is a commented snippet of the command to use as a reference.

```shell
(...)
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  # change out the hostname references to match your environment
  # as well as the private IP addresses in the section below
  # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
(...)
```

In keeping with the example hostnames and addresses that this guide uses, It would look something like this.

```shell
(...)
--initial-cluster ctrl-1=https://10.240.0.3:2380,ctrl-2=https://10.240.0.4:2380,ctrl-3=https://10.240.0.5:2380 \\
(...)
```

When you verify later in the KTHW walkthrough, it should reflect the proper values - something like this:

```shell
3c2bc8e73d7699f6, started, jose-ctrl-1, https://10.240.0.3:2380, https://10.240.0.3:2379
19d579b62edebc85, started, jose-ctrl-2, https://10.240.0.4:2380, https://10.240.0.4:2379
fd6c0c301abe1480, started, jose-ctrl-3, https://10.240.0.5:2380, https://10.240.0.5:2379
```

## [08-bootstrapping-kubernetes-controllers.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/08-bootstrapping-kubernetes-controllers.md)

This document starts with a `gcloud compute ssh` command that can be trimmed down to simply `ssh`. As a reminder, you'll need to be using `tmux` or similar to broadcast commands across all controllers.

#### Configure the Kubernetes API Server

This section makes a reference to the `INTERNAL_IP` variable being pulled on each controller using the gcloud metadata API. As we've seen previously, we should have this set in `~/.bash_aliases` but if it's missing we can set it dynamically:

```shell
test ! -z ${INTERNAL_IP} || INTERNAL_IP=4(ifconfig eth2 | awk '/inet\ / { print $2 }')
```

You will also create the `kube-apiserver.service` systemd unit file, which makes a reference to your etcd servers configured in the last section. We need to make adjustments to this command as you've done previously as the IP addresses referenced may not match yours. Here's a commented snippet indicating the command flag we're adjusting:

```shell
  --enable-swagger-ui=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  # Change the below etcd servers to match your environment
  # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  --etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379,https://10.240.0.12:2379 \\
  # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  --event-ttl=1h \\
  --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
```

If you have configured entries for your controllers in `/etc/hosts`, you should be able to substitute the flag with the following to dynamically resolve those entries.

```shell
  --etcd-servers=https://$(dig +short ctrl-1):2379,https://$(dig +short ctrl-2):2379,https://$(dig +short ctrl-3):2379 \\
```

Otherwise, manually make the adjustments, and then copy the entire entry into the broadcasting terminal session.

#### Enable HTTP Health Checks

The justification for this section revolves around functionality of Google's Cloud Network Load Balancer which does not allow for HTTPS-based health checks. Rackspace Cloud Load Balancer's have a similar limitation, in that you're unable to define settings necessary to verify an SSL certificate from a custom CA or disable SSL verification. The result is that your nodes will be marked down.

Rackspace Cloud Load Balancers also don't allow specifying a different endpoint for the health check as KTHW's implementation of this health check implies (health check on port 80, but traffic hitting port 6443). Read through this section, but you can skip it in its entirety. Instead use this spot to go ahead and add your controller instances to your Cloud Load Balancer. Define protocol **HTTPS** with Port **6443**, and the backend traffic should also target the individual instances on port **6443**. Understand that we're passing traffic straight back to the backend servers, and as such are doing no SSL termination of any kind at the Cloud Load Balancer.

Throughout the remainder of these labs, any reference to testing the Cloud Load Balancer's health checks can be disregarded.

#### RBAC for Kubelet Authorization

There is a reference to `gcloud compute` for `ssh` purposes. Simply leave the gcloud pieces out.

#### The Kubernetes Frontend Load Balancer

A majority of this section revolves around utilizing the `gcloud` command to provision the load balancer. For us, this means finalizing the configuration of your Cloud Load Balancer if you haven't done so already (in the **Enable HTTP Health Checks** section). 

Add your three controller nodes to your load balancer and pass traffic directly back to port 6443 via HTTPS.

![raxcloud-lb-nodes](/images/kthw-raxcloud-lb-nodes.png)

You can initiate the the same verification steps this section uses once your backend nodes are in place. The `KUBERNETES_PUBLIC_ADDRESS` should be exported into your environment via your `~/.bash_aliases` file.

## [09-bootstrapping-kubernetes-workers.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/09-bootstrapping-kubernetes-workers.md)

By now you're likely a pro at this particular task, but this lab begins with executing `ssh` via the `gcloud` command. Simply remove `gcloud compute` to initiate your SSH client. In addition, this document does require running your commands on all three worker nodes simultaneously, so break out `tmux` or similar for this lab.

#### Configure CNI Networking

You'll start this section by setting each worker node's POD_CIDR environment variable by pulling the metadata that was associated with the instance (at launch time) from gcloud. For simplicity's sake, simply set the variables manually - remembering that you need a unique third octet. Here's an example for each node:

```shell
(worker-1)# 10.200.0.0/24 

(worker-2)# 10.200.1.0/24

(worker-3)# 10.200.2.0/24
```

If you anticipate having to pause the lab and pick it up later, add the respective POD_CIDR values to the `~/.bash_aliases` so you don't need to re-add them later.

```shell
echo 'export POD_CIDR='"${POD_CIDR}" >> ~/.bash_aliases
```

#### Configure the Kubelet

When creating the `kubelet-config.yaml` file, you'll make a reference to the POD_CIDR variable that you provisioned for each node. Make sure the variable is set before you create the yaml files.

#### Verification

The final verification uses the `gcloud` utility - remove these pieces to ssh directly to the indicated controller node.

## [10-configuring-kubectl.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/10-configuring-kubectl.md)

This document reminds you to run these commands from the same direction and location where you generated certificates. If you created a "workstation" instance, that's the location where the next lab needs to take place.	

## [11-pod-network-routes.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/11-pod-network-routes.md)

This lab will need to be handled drastically differently. What you accomplish here is pod-network routing from worker to worker, as their respect pod cidr networks only exist locally. In gcloud, this is handled by creating what appeares to be host routes which trickle down to the instances.

For our purposes, we're simply going to edit the routes at our instance level and make them persist on reboot. Note that this will not persist on network-changing actions (such as adding an additional network via the Rackspace Control Panel). For a lab, this approach will suffice.

Each worker node needs two additional routes added to allow for each individual worker to access the additional pod cidr networks you defined for the other two workers. Rackspace's Ubuntu 18.04 images utilize [NetPlan](https://netplan.io/). You should find your configuration in `/etc/netplan/rackspace-cloud.yml`. I've added routes to the `eth2` configuration in this file to bring up two additional routes. Here's a heavily commented example of what that looks like on one of my worker nodes:

```yaml
network: # network configuration of worker-1
  ethernets:
    eth0:
	  (...)
    eth1:
      (...)
# the below configuration is associated with the additional
# network we created with this instances.
    eth2:
      addresses:
      - 10.240.0.6/24
      dhcp4: false
      # THIS node had a pod cidr of 10.200.1.0/24.
      # the other workers had 10.200.[23].0/24 so
      # we need to route to them via the private network
      routes:
      - to: 10.200.2.0/24 # pod-cidr of worker-2
        via: 10.240.0.7   # the internal/private network address of worker-2
      - to: 10.200.3.0/24 # pod-cidr of worker-3
        via: 10.240.0.8   # the internal/private network address of worker-3
```

You will need to repeat this for the remaining workers, swapping out their respective pod cidr networks and defining their private network addresses as the gateway.

Once you've completed this, you will want to generate a reuasble configuration, and apply the configuration

```shell
netplan generate
netplan apply
```

Finally, verify that your routes have been added:

```shell
route -n
```

Expected output should include these lines (with networks adjusted to match your environment):

```
10.200.2.0      10.240.0.7      255.255.255.0   UG    0      0        0 eth2
10.200.3.0      10.240.0.8      255.255.255.0   UG    0      0        0 eth2
```

## [12-dns-addon.md](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/bf2850974e19c118d04fdc0809ce2ae8a0026a27/docs/12-dns-addon.md)

There are no changes necessary for this article. If you encounter issues resolving domains, confirm that your inter-pod connectivity has been done correctly. Do make note, however, that instances in the same private network spun up in gcloud will resolve each other's names without additional configuration. The Rackspace Cloud does not have this implemented in the same way. If you haven't already, add `/etc/hosts` entries detailed during host provisioning on this document mapping every worker/controller's private IP addresses to their short hostnames.

## Final Thoughts

Having to translate from one infrastructure provider to another could easily cause some hang ups when learning new concepts. Hopefully this provides a bit of guidance for translating concepts, and encourages others to approach Kubernetes the Hard Way regardless of the provider of choice.

Happy Learning!

