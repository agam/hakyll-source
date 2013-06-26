---
title: Appengine transition from Python to Go
date: 2013-06-22
---

Appengine transition from python to Go
======================================

Hadn't updated this blog for a few months, and neither the "personal web site" that I had started earlier. So, to try something new, I decided to port that appengine site from python to go (looking at the Github logs, I haven't updated that for 2 years !!)

The `app.yaml` is changed to get rid of all non-static handlers (which are now declared inside the `func init()` in the `.go` file. So the only handlers will be `/static`, `/robots.txt`, and `/.*`.

Both the [Appengine docs](https://developers.google.com/appengine/docs/go/) as well as [a couple](http://cuddle.googlecode.com/hg/talk/index.html) [of examples](http://jan.newmarch.name/go/chinese/chapter-chinese.html) have basic bootstrapping information.

The first thing I did was to make a barebones "Hello World" index handler, and run it with

```shell
$ google_appengine/dev_appserver.py <path to my app>
```

But I immediately got this error:

```shell
google.appengine.tools.devappserver2.wsgi_server.BindError: Unable to find a consistent port localhost
Exception in thread Thread-4 (most likely raised during interpreter shutdown):
Traceback (most recent call last):
  File "/usr/lib/python2.7/threading.py", line 551, in __bootstrap_inner
  File "/usr/lib/python2.7/threading.py", line 504, in run
  File "/home/agam/Documents/Code/google_appengine/google/appengine/api/taskqueue/taskqueue_stub.py", line 2014, in MainLoop
  File "/home/agam/Documents/Code/google_appengine/google/appengine/api/taskqueue/taskqueue_stub.py", line 2006, in _Wait
  File "/usr/lib/python2.7/threading.py", line 403, in wait
  File "/usr/lib/python2.7/threading.py", line 258, in wait
<type 'exceptions.TypeError'>: 'NoneType' object is not callable
```

After some Googling and Stackoverflowing, I found a somewhat bizarre fix (to use `--api_port` argument) with the root cause identified as being duplicate `localhost` mappings in the `/etc/hosts` file, including ipv6 mappings to localhost. Now I don't want to mess up my `/etc/hosts` with what is certainly a _bad idea_, so I used the `--api_port` option and I saw the 'hello world'. So far, so good.

I had terrible fonts from long ago, and since Google Web Fonts has become pretty awesome since then, headed on over to pick a few custom fonts. Also realized that I really just need to keep the index page, since the custom blog that I started is really superseded by this one and the posterous feed tracker was obsolete some time ago.

The handler idea is quite straightforward, and there is definitely less boilerplate than what `index.py` was using earlier.

Initial stupid error: All requests were going to the same handler (including static css ones). Had to change url order in `app.yaml` to move the `/static` above the `/.*`.

Ok, all set, the barebones appengine site is up and running, I hope I can add some fun stuff to this in the future!

*Update*:
We aren't done yet; after I uploaded the app (`appcfg.py update`, which by the way prefers `--oauth2` but won't tell you about it) the html wasn't being served.
I added a `log.Fatal()` and sure enough the file wasn't being read any more.

This was also a good time to see error handling in place, the application logs showed

```shell
panic: os.Exit called
runtime.panic go/src/pkg/runtime/panic.c:230
os.Exit go/src/pkg/os/proc.go:42
log.Fatal go/src/pkg/log/log.go:289
agamsweb.indexHandler agamsweb/agamsweb.go:18
net/http.HandlerFunc.ServeHTTP go/src/pkg/net/http/server.go:1150
net/http.(*ServeMux).ServeHTTP go/src/pkg/net/http/server.go:1417
appengine_internal.executeRequestSafely go/src/pkg/appengine_internal/api_prod.go:248
appengine_internal.(*server).HandleRequest go/src/pkg/appengine_internal/api_prod.go:198
reflect.Value.call go/src/pkg/reflect/value.go:474
reflect.Value.Call go/src/pkg/reflect/value.go:345
_ _.go:316
runtime.goexit go/src/pkg/runtime/proc.c:280
```

While testing this I also ran into an appengine bug: it is possible to get the following error message, though it literally doesn't make much sense

```shell
E 2013-06-23 11:53:32.539
Request failed because the app binary was missing. This can generally be fixed by redeploying your app.
I 2013-06-23 11:53:32.539
This request caused a new process to be started for your application, and thus caused your application code to be loaded for the first time.
This request may thus take longer and use more CPU than a typical request for your application.
```
(i..e how can the app binary be missing _after_ the application was loaded? :) )

After much digging, realized that it isn't possible to read files specified by the `static` handler.

Hmm so I don't really need any go code to do anything meaningful right now, I'll leave 'hello world' running :/
