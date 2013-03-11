---
title: Setting up a Haskell webserver to run in Google Compute Engine
date: 11 Mar 2013
---

Setting up a Haskell webserver to run in Google Compute Engine
==============================================================

I signed up for a project at the [Google Cloud Console](https://cloud.google.com/console#c=l), and decided to try running a webserver on it, as a prerequisite to other future toy projects I might link to it.

First steps
-------------

Get [```gcutil```](https://developers.google.com/compute/docs/gcutil/) and install it

```shell
$ sudo tar xvpzf gcutil-1.7.1.tar.gz  -C /usr/local/share
$ sudo ln -s /usr/local/share/gcutil-1.7.1/gcutil /usr/local/bin/gcutil
```

Then, link it up to your project

```shell
$ gcutil auth --project=agam-personal-project
```

It's a good idea to avoid entering the ```--project=``` bit every time, by saving your project name

```shell
$ gcutil getproject --project=agam-personal-project --cache_flag_values
+--------------------------+-------------------------------+
|         property         |             value             |
+--------------------------+-------------------------------+
| name                     | agam-personal-project                     |
| description              |                               |
| creation-time            | 2012-10-30T13:52:46.571-07:00 |
| ips                      | 108.59.85.232,173.255.125.245 |
|                          |                               |
| usage                    |                               |
|   instances              | 0.0/4.0                       |
|   cpus                   | 0.0/4.0                       |
|   ephemeral-addresses    | 0.0/4.0                       |
|   disks                  | 0.0/4.0                       |
|   disks-total-gb         | 0.0/250.0                     |
|   snapshots              | 0.0/20.0                      |
|   networks               | 1.0/1.0                       |
|   firewalls              | 2.0/10.0                      |
|   images                 | 0.0/4.0                       |
|                          |                               |
| common-instance-metadata |                               |
+--------------------------+-------------------------------+
```

By default, incoming HTTP is blocked. So enable it.

```shell
$ gcutil addfirewall http2 --description="Allow incoming http" --allowed="tcp:http"
INFO: Waiting for insert of firewall http2. Sleeping for 3s.
INFO: Waiting for insert of firewall http2. Sleeping for 3s.

Table of resources:

+-------+---------------------+------------------+------------+-------------+-------------+
| name  |     description     |     network      | source-ips | source-tags | target-tags |
+-------+---------------------+------------------+------------+-------------+-------------+
| http2 | Allow incoming http | networks/default | 0.0.0.0/0  |             |             |
+-------+---------------------+------------------+------------+-------------+-------------+

Table of operations:

+------------------------------------------------+------+--------+----------------+-----------------+-------------------------------+----------------+-------+---------+
|                      name                      | zone | status | status-message |     target      |          insert-time          | operation-type | error | warning |
+------------------------------------------------+------+--------+----------------+-----------------+-------------------------------+----------------+-------+---------+
| operation-1362984707558-4d7a09b531841-ea2eb01d |      | DONE   |                | firewalls/http2 | 2013-03-10T23:51:47.558-07:00 | insert         |       |         |
+------------------------------------------------+------+--------+----------------+-----------------+-------------------------------+----------------+-------+---------+
```

And now it's time to make choices!

```shell
gcutil addinstance basic-webserver-instance
1: europe-west1-a  (currently in maintenance)
2: europe-west1-b
3: us-central1-a
4: us-central1-b
5: us-central2-a
>>> 3
```

No particular reason, I picked ```us-central1-a``` (why no ```us-west``` ?). I wasn't sure which [instance type](https://cloud.google.com/pricing/compute-engine) to pick ... I went with the cheapest option with a disk (#2) for now.

```shell
1: n1-standard-1
2: n1-standard-1-d
3: n1-standard-2
4: n1-standard-2-d
5: n1-standard-4
6: n1-standard-4-d
7: n1-standard-8
8: n1-standard-8-d
9: n1-highcpu-2
10: n1-highcpu-2-d
11: n1-highcpu-4
12: n1-highcpu-4-d
13: n1-highcpu-8
14: n1-highcpu-8-d
15: n1-highmem-2
16: n1-highmem-2-d
17: n1-highmem-4
18: n1-highmem-4-d
19: n1-highmem-8
20: n1-highmem-8-d
>>> 2
```

10 choices of a host OS, I picked what seemed to be the latest ```gcel``` one.

```shell
1: projects/google/global/images/centos-6-v20121106
2: projects/google/global/images/centos-6-v20130104
3: projects/google/global/images/centos-6-v20130225
4: projects/google/global/images/gcel-10-04-v20121106
5: projects/google/global/images/gcel-10-04-v20130104
6: projects/google/global/images/gcel-10-04-v20130225
7: projects/google/global/images/gcel-12-04-v20121106
8: projects/google/global/images/gcel-12-04-v20130104
9: projects/google/global/images/gcel-12-04-v20130225
10: projects/google/global/images/centos-6-v20120912 (DEPRECATED)
>>> 9
```

If this is the first time running ```gcutil``` it will ask you to enter a passphrase for authentication, and then your instance should be inserted. As you can see below, this took about 35s for me.

```shell
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.
INFO: Waiting for insert of instance basic-webserver-instance. Sleeping for 3s.

Table of resources:

+--------------------------+------------------------------+----------------------------------------------------+------------------+---------------+---------------+-------+---------------+---------+----------------+
|           name           |         machine-type         |                       image                        |     network      |  network-ip   |  external-ip  | disks |     zone      | status  | status-message |
+--------------------------+------------------------------+----------------------------------------------------+------------------+---------------+---------------+-------+---------------+---------+----------------+
| basic-webserver-instance | machineTypes/n1-standard-1-d | projects/google/global/images/gcel-12-04-v20130225 | networks/default | 10.240.31.254 | 108.59.80.144 |       | us-central1-a | RUNNING |                |
+--------------------------+------------------------------+----------------------------------------------------+------------------+---------------+---------------+-------+---------------+---------+----------------+

Table of operations:

+------------------------------------------------+---------------+--------+----------------+--------------------------------------------------+-------------------------------+----------------+-------+---------+
|                      name                      |     zone      | status | status-message |                      target                      |          insert-time          | operation-type | error | warning |
+------------------------------------------------+---------------+--------+----------------+--------------------------------------------------+-------------------------------+----------------+-------+---------+
| operation-1362986355529-4d7a0fd8d07a1-a21d7f92 | us-central1-a | DONE   |                | us-central1-a/instances/basic-webserver-instance | 2013-03-11T00:19:15.529-07:00 | insert         |       |         |
+------------------------------------------------+---------------+--------+----------------+--------------------------------------------------+-------------------------------+----------------+-------+---------+
```

You can then check if the instance matches what you wanted.

```shell
$ gcutil getinstance basic-webserver-instance
(output skipped)
```

Installing Stuff
----------------------

Now that the instance is ready to go, you can ssh to it and get the stuff we need.

```shell
$ gcutil ssh basic-webserver-instance
...
... (skipping boilerplate)
... 
 * You appear to be running on an EPHEMERAL root disk.  Changes may be lost.
  For persistent data, use Persistent Disks:
  https://developers.google.com/compute/docs/disks#persistentdisks

agam@basic-webserver-instance:~$ sudo df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       9.6G 1019M  8.1G  12% /
none            1.9G  4.0K  1.9G   1% /dev
none            377M  140K  377M   1% /run
none            5.0M     0  5.0M   0% /run/lock
none            1.9G     0  1.9G   0% /run/shm
```

Yeah, the instance doesn't come with a persistent disk. So if you decide to delete the instance, your data is gone.

Eventually, I'll attach [persistent disks](https://developers.google.com/compute/docs/disks#persistentdisks) and also use a [startup script](https://developers.google.com/compute/docs/robustsystems#startup) to allow me to quickly recreate VM state on new instances, but I'll punt on those for now.

Anyway, let's start installing stuff

```shell
$ sudo apt-get install haskell-platform
...
$ cabal update
...
$ cabal install yesod-platform
...
```

Haskell packages are still a bit flaky. For instance, I got this error and had to ignore it and pray nothing broke:

```shell
Warning: The following packages are likely to be broken by the reinstalls:
regex-posix-0.95.1
```

BTW this takes a _long_ _long_ time to complete, so go do something else for 5-10 minutes and then come back.

Running Yesod
---------------

For this example, I'm going to do a basic webserver, though the right thing to do in this case is to choose the option to configure the urls to be used with [Google Cloud Storage](https://developers.google.com/storage/docs/getting-started)

```shell
agam@basic-webserver-instance:~$ yesod init
Welcome to the Yesod scaffolder.
I'm going to be creating a skeleton Yesod project for you.

What do you want to call your project? We'll use this for the cabal name.

Project name: AgamsWeb
Yesod uses Persistent for its (you guessed it) persistence layer.
This tool will build in either SQLite or PostgreSQL or MongoDB support for you.
We recommend starting with SQLite: it has no dependencies.

    s      = sqlite
    p      = postgresql
    pf     = postgresql + Fay (experimental)
    mongo  = mongodb
    mysql  = MySQL
    simple = no database, no auth
    url    = Let me specify URL containing a site (advanced)

So, what'll it be? s
```

This sets up a basic scaffold with a few directories

```shell
agam@basic-webserver-instance:~/AgamsWeb$ ls -l
total 68
-rw-rw-r-- 1 agam agam 3907 Mar 11 08:18 AgamsWeb.cabal
-rw-rw-r-- 1 agam agam 2723 Mar 11 08:18 Application.hs
-rw-rw-r-- 1 agam agam 6583 Mar 11 08:18 Foundation.hs
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 Handler
-rw-rw-r-- 1 agam agam 1057 Mar 11 08:18 Import.hs
-rw-rw-r-- 1 agam agam  415 Mar 11 08:18 Model.hs
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 Settings
-rw-rw-r-- 1 agam agam 2736 Mar 11 08:18 Settings.hs
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 app
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 config
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 deploy
-rw-rw-r-- 1 agam agam  709 Mar 11 08:18 devel.hs
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 messages
drwxrwxr-x 4 agam agam 4096 Mar 11 08:18 static
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 templates
drwxrwxr-x 2 agam agam 4096 Mar 11 08:18 tests
```

Now to start this (empty) webserver

```shell
$ cabal install
$ yesod devel
```

This starts the server on ```localhost:3000```. Now the Yesod folks recommend running ```nginx``` as a reverse proxy in front, so let's do that (though it's obviously overkill for this example).

```shell
$ sudo apt-get install nginx
```

Create a basic reverse proxy config

```yaml
events {
    worker_connections 4096;
}

http {
    server {
        listen 80;
        location / {
            proxy_pass http://127.0.0.1:3000/;
        }
    }
}
```

Then run nginx

```shell
sudo nginx -c nginx.conf
```

Hmm ... ok ... for whatever reason that didn't work. This seems like a fairly straightforward config. Screw it, run yesod directly on port 80.

```shell
sudo yesod devel --port=80
```

Now, if you open the associated IP in your browser, you should see the standard "Welcome to Yesod" placeholder !!

