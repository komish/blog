---
title: Troubleshooting Upgrades from Gitea 1.11 to Gitea 1.13
publishDate: 2021-04-01
categories: [Walkthrough]
tags: [gitea, mariadb, self-hosted]
description: Putting in some extra legwork to upgrade Gitea to version 1.13
---

![giteasplash](/images/gitea-upgr-troubleshooting-splash.png)


I run an internal [Gitea](https://gitea.io/en-us/) server for personal use. I
initially started with the [Go Git Service](https://gogs.io/) ("gogs") and
converted to Gitea several years ago. The stack is pretty simple. I run Gitea on
a CentOS 7 server, and have it pointed to a MariaDB 5.5 cluster configured for
2-node replication.

I was running `gitea-1.11.3` and the latest version as of this post is
`gitea-1.13.6`. Naturally, this means its time for an upgrade, and historically
these upgrades have been painless. Apparently, I was overdue for some upgrade
woes.

My typical workflow for upgrade Gitea is simply to:

* Take a quick database backup (`mysqldump ...`)
* Stop gitea (`systemctl stop gitea`)
* Download the new binary (`wget ...`)
* Change a few symlinks around (so that the new binary is what's being called by
  systemd)
* Restart the service and watch the logs to make sure everything is working
  smoothly.

The `gitea` command includes a `dump` subcommand that can be used to take a
[proper backup](https://docs.gitea.io/en-us/backup-and-restore/) of an
installation. I've used it before but forgot about it for this upgrade.  In a
worst case scenario, I was prepare to re-initialize my installation.

After I performed the upgrade, I saw the following log lines in my `gitea.log`
files indicating that I had a problem.

```
2021/04/01 00:00:00 routers/init.go:156:GlobalInit() [F] ORM engine initialization failed: migrate: do migrate: Error 1071: Specified key was too long; max key length is 767 bytes
```

That's not great! After some searching on the web, I found this issue
[https://github.com/go-gitea/gitea/issues/13588](https://github.com/go-gitea/gitea/issues/13588)
which seems to be a close-enough scenario for what I'm experiencing. Close
enough, at least, to justify that I start working on the resolution as described
(which means I roughly parsed the comments and decided I was going to move
forward with no other justification other than "why not").

I obviously didn't parse this comment well enough, because the very last
[comment](https://github.com/go-gitea/gitea/issues/13588#issuecomment-753829791)
specifies that using `gitea convert` may have solved my issue outright. Instead,
I reached for a
[comment](https://github.com/go-gitea/gitea/issues/13588#issuecomment-728269561)
specifying that I do the following:

> Best solution would be to upgrade mariadb to 10.2.2+
>
> *-- lafriks commented on Nov 16, 2020*

CentOS7's repos don't seem to have this available, so I ended up installing this
using MariaDB's upstream
[documentation](https://mariadb.com/kb/en/yum/#using-the-mariadb-repository-configuration-tool)
on the subject. It suggests using their installer script and then piping that to
bash. That's exactly what I did, despite my general aversion to this type of
`curl script-from-internet.sh | bash` (... why not just provide us the repo
definitions to install ourselves?).

Performing this upgrade on the databases was pretty straight forward. Remember
that I have a replication configuration, so the overall gist of this workflow
was something like:

* stop Replicant
* stop Master
* remove old version on master
* install new version on master
* restore configuration on master
* start master
* remove old version on replicant
* install new version on replicant
* restore configuration on replicant
* start replicant
* check SQL/IO threads for replication health
* enable both services to start on reboot (`systemcl enable mariadb.service`)

A step I skipped here was running `mysql_uprade`, so I ran into this issue on
the replicant once I had started everything up:


```
Unable to load replication GTID slave state from mysql.gtid_slave_pos: Table 'mysql.gtid_slave_pos' doesn't exist
```

This output was seen in the `show slave status\G` command on the replicant. Some
more internet searching led me to the `mysql_upgrade` command, which should be
executed on both nodes. Not knowing a clear order in which I should apply, I
went ahead and stopped the replicant and ran `mysql_upgrade` on the master. No
issues there, so I followed that with a restart of the Master. After running the
upgrade logic, I started the replicant and still saw the error as mentioned
above. I went ahead and ran the `mysql_upgrade` on the replicant without issue
and restarted the server. Everything was healthy and happy after that.

It was finally time to start the `Gitea` application. Now I've run into my final
issue, below, as seen in the `gitea.log` file:

```
2021/04/01 00:00:00 routers/init.go:156:GlobalInit() [F] ORM engine initialization failed: migrate: do migrate: Sync2: Unknown colType DATETIME /* MARIADB-5.3 */
```

Welp, that doesn't look right! Some more internet searching and I see this issue
for the gogs repository from late 2020 ->
[https://github.com/gogs/gogs/issues/6423](https://github.com/gogs/gogs/issues/6423).


The basic explanation was provided by the original poster:

> After a while I discovered MySQL/Mariadb changed some internal time formats
> and columns that have not been upgraded and use the old temporal format show
> /* MARIADB-5.3 */ appended to their type. I'm guessing gogs database object
> system does not handle that very well? So I updated the tables that were using
> datetime by modifying them to use the same type as this causes the upgrade as
> documented at Timestamp: Internal Format
> (https://mariadb.com/kb/en/timestamp/#internal-format).

The suggested fix was to effectively run `ALTER TABLE` commands on the database
to update the column type of things that were apparently using an internal
format (potentially related to MariaDB 5.3, but I can't be sure as I didn't
really look too closely at the database documentation here).

With this in mind, I decided I was comfortable with the modification and decided
to see just how many tables needed the change. I ran this command to find out
what table columns needed adjustment:

```
$ for i in $(cat tables); do echo "-- ${i} -- "; mysql -Ne "describe ${i};" git | grep mariadb-5.3 ; done
```

I ended up with this list.

```
-- access_token -- 
created datetime /* mariadb-5.3 */  YES     NULL    
updated datetime /* mariadb-5.3 */  YES     NULL    
-- action -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- attachment -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- collaboration -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- comment -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- deploy_key -- 
created datetime /* mariadb-5.3 */  YES     NULL    
updated datetime /* mariadb-5.3 */  YES     NULL    
-- external_login_user -- 
expires_at  datetime /* mariadb-5.3 */  YES     NULL    
-- issue -- 
deadline    datetime /* mariadb-5.3 */  YES     NULL    
created datetime /* mariadb-5.3 */  YES     NULL    
updated datetime /* mariadb-5.3 */  YES     NULL    
-- lfs_lock -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- lfs_meta_object -- 
-- login_source -- 
created datetime /* mariadb-5.3 */  YES     NULL    
updated datetime /* mariadb-5.3 */  YES     NULL    
-- milestone -- 
deadline    datetime /* mariadb-5.3 */  YES     NULL    
closed_date datetime /* mariadb-5.3 */  YES     NULL    
-- mirror -- 
updated datetime /* mariadb-5.3 */  YES     NULL    
next_update datetime /* mariadb-5.3 */  YES     NULL    
-- notice -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- public_key -- 
created datetime /* mariadb-5.3 */  YES     NULL    
updated datetime /* mariadb-5.3 */  YES     NULL    
-- pull_request -- 
merged  datetime /* mariadb-5.3 */  YES     NULL    
-- release -- 
created datetime /* mariadb-5.3 */  YES     NULL    
-- repository -- 
created datetime /* mariadb-5.3 */  YES     NULL    
updated datetime /* mariadb-5.3 */  YES     NULL    
```

Not too bad. I prepared a few SQL statements to run with these tables and
columns defined and executed them on my replication master.

```sql
ALTER TABLE `webhook` MODIFY created DATETIME;
ALTER TABLE `webhook` MODIFY updated DATETIME;
ALTER TABLE `user` MODIFY created DATETIME;
ALTER TABLE `user` MODIFY updated DATETIME;
ALTER TABLE `repository` MODIFY created DATETIME;
ALTER TABLE `repository` MODIFY updated DATETIME;
ALTER TABLE `release` MODIFY created DATETIME;
ALTER TABLE `pull_request` MODIFY merged DATETIME;
ALTER TABLE `public_key` MODIFY created DATETIME;
ALTER TABLE `public_key` MODIFY updated DATETIME;
ALTER TABLE `notice` MODIFY created DATETIME;
ALTER TABLE `mirror` MODIFY updated DATETIME;
ALTER TABLE `mirror` MODIFY next_update DATETIME;
ALTER TABLE `milestone` MODIFY deadline DATETIME;
ALTER TABLE `milestone` MODIFY closed_date DATETIME;
ALTER TABLE `login_source` MODIFY created DATETIME;
ALTER TABLE `login_source` MODIFY updated DATETIME;
ALTER TABLE `lfs_lock` MODIFY created DATETIME;
ALTER TABLE `issue` MODIFY deadline DATETIME;
ALTER TABLE `issue` MODIFY created DATETIME;
ALTER TABLE `issue` MODIFY updated DATETIME;
ALTER TABLE `external_login_user` MODIFY expires_at DATETIME;
ALTER TABLE `deploy_key` MODIFY created DATETIME;
ALTER TABLE `deploy_key` MODIFY updated DATETIME;
ALTER TABLE `comment` MODIFY created DATETIME;
ALTER TABLE `collaboration` MODIFY created DATETIME;
ALTER TABLE `attachment` MODIFY created DATETIME;
ALTER TABLE `action` MODIFY created DATETIME;
ALTER TABLE `access_token` MODIFY created DATETIME;
ALTER TABLE `access_token` MODIFY updated DATETIME;
```

I executed those and ended up with this response (obviously I did this for all
tables listed above, but I'm only showing a single entry for brevity):

```sql
> ALTER TABLE `webhook` MODIFY created DATETIME;
Query OK, 1 row affected (0.016 sec)               
Records: 1  Duplicates: 0  Warnings: 0
```

After starting up Gitea, everything was happy and I had no further issues. Happy
hacking!
