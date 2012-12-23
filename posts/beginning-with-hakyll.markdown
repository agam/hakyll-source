---
title: Beginning Hakyll
date: 12/22/2012
---

Getting up and running with Hakyll
========================================

I looked around at the usual suspects (wordpress, blogspot, etc) but then stumbled across the recent static website idea when I read "powerd by Jekyll" in a blog footer. Soon enough I came across Hakyll, and decided to give it a go, if only to learn Haskell a bit better.

The first few examples I came across were hosted on Linode etc, so my initial plan was to use this new blog to try out another new (for me) tool and host it on Google Compute Engine. But after reading up a bit on that, I realized I didn't want to deal with provisioning and storage and all, and that's when I realized that I could just host it on a platform that already supports static websites: Github Pages.

So there are a few steps here: getting hakyll, setting it up for my blog, setting it up with github, etc, and I'll go over them, in no particular order.

Getting Hakyll
--------------------

```shell
cabal install hakyll
```

This will fetch al the required packages (and it took *quite* some time when I ran it, roughly as long as it might take ~~me~~one to torrent an episode of a television series that ~~I am~~one is currently watching). Of course, this depends on you already having `cabal` installed. If not, you should get the [Haskell Platform](http://www.haskell.org/platform/) first.

If this works as intended, you should see a lot of output as `cabal` goes and compiles and installs a bunch of packages, ending with something like this:

~~~
Installing library in /home/agam/.cabal/lib/hakyll-3.4.0.0/ghc-7.4.1
Registering hakyll-3.4.0.0...
~~~

Know how to use git and github
-------------------------------

I'm assuming you have atleast an newbie level understanding of [git](http://git-scm.com/) (which is what I have) and an account at [github](http://www.github.com).

This [list of git tutorials](http://sixrevisions.com/resources/git-tutorials-beginners/) is a good starting point to learn git, though I recommend [Git Magic](http://www-cs-students.stanford.edu/~blynn/gitmagic/) (if only because I know the author, and frankly I found other tutorials either shallow or boring, by comparison).

If you haven't used either git *or* github previously, I would recommend going through [Try Github](http://try.github.com/) as it does a good job of walking you through the few core workflows you'll need to use.

Know **some** haskell
----------------------

Ok, this is something I can't talk about here, mostly because I don't know it well myself, but also because it is really, really beyond the scope of this blog.

You can [try haskell](http://tryhaskell.org/) for a while and come back; my personal opinion is that it's overhyped as being hard, while actually being sort of fun, and people who try to sell it to you as some mystical super-hard iq-prerequisite-required sort of thing are just $@#holes. 

Still, you do need to know atleast some Haskell to use Hakyll, so I'll leave it at that.

Set up github
--------------------

To host github pages, you need to create a repo of the form `username/username.github.com`. So [do that now](https://github.com/new).
The code for the site will live in a different repo (yeah, this part is a drag compared to Jekyll, where github 'automagically' build the blog on commit, and then takes care of serving the right pages.

To get the same effect in our hakyll blog here, we'll have to set the pages repo as a *submodule* of the source repo. To do that, run

```shell
git submodule add https://github.com/agam/agam.github.com.git _site

```

Don't forget to add the second argument specifying the folder that the submodule is embedded under.

If you leave this out, it will be embedded under the name of the repo (e.g. in this case, there would be a directory created called `agam.github.com`). I did this, and then had to do the following to get rid of it :-

(Thanks to [this stackoverflow post](http://stackoverflow.com/questions/1260748/how-do-i-remove-a-git-submodule)!)

1. Edit `.gitmodules` to remove the offending section. In my case, this showed up as
```
[submodule "agam.github.com"]
	path = agam.github.com
	url = https://github.com/agam/agam.github.com.git
```

2. Remove the corresponding section from `.git/config`. In my case, this showed up as
```
[submodule "agam.github.com"]
	url = https://github.com/agam/agam.github.com.git
``` 

3. Run `git rm` to remove the directory. Again, in my case, this meant running `git rm --cached agam.github.com`


Setting up hakyll: Overview
----------------------------

Now for the actual structure of the blog, there are two ways to go: My plan is to go with the [basic example](https://github.com/jaspervdj/hakyll-examples/tree/master/brochure) in the [rudimentary hakyll docs](http://jaspervdj.be/hakyll/tutorials/02-basics.html) and build up from there to add support for multiple posts, pages, widgets, comments, etc.

The other option is to use one of the [existing large, customized hakyll blogs](http://jaspervdj.be/hakyll/examples.html) and adapt them to your use.

Which option you use is up to you, the rest of this blog post talks about initial changes I made to the example site, and I'll mention any additional structural features in a separate blog post.

Setting up hakyll: Details
------------------------------

You can ignore this part really, if you've successfully adapted the other blogs as mentioned above. I'm taking the approach of starting with a single index page with a single post and building up from there.

So in the first iteration, I had a `css` folder (with the same contents as the example) and a `templates` folder (which contained a barebones `default.html`). I had a file `blog.hs` with this code:

```Haskell
{-# LANGUAGE OverloadedStrings #-}

import Control.Arrow ((>>>))

import Hakyll

main :: IO()
main = hakyll $ do
    match "images/*" $ do
        route    idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route    idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateCompiler

    match (list ["about.markdown", "index.markdown"]) $ do
        route     $ setExtension "html"
        compile   $ pageCompiler
	    >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

```

To generate the static html, run

```Shell
ghc --make blog.hs
```

(Now this is the point where the 'know some haskell' rule applies, since if you're like me, you'll make some stupid typo and have to contend with something like

```
    Couldn't match expected type `RulesM b0'
                with actual type `cat0 a0 c0'
```

and wonder *wtf* just happened ... in this case, I hadn't indented the arrows between the compilers in the last two lines!)

If all goes well, you should see

```
[1 of 1] Compiling Main             ( blog.hs, blog.o )
Linking blog ...
```

Then, run

```
./blog build
```

(replace 'blog' with whatever `foo.hs` contains the 'main' function)

This is where I encountered another error:

```
  [ ERROR] Hakyll.Web.readPandocWith: I don't know how to read a file of the type Binary for: about.pandoc
```

(Once again, my typo: I had used `about.pandoc` when I meant to say, of course, `about.markdown`. Recompiled, built, saw the following:

```
Initialising
  [   0ms] Creating store
  [  15ms] Creating provider
Adding new compilers
Compiling templates/default.html
  [      ] Checking cache: OK
  [   0ms] Total compile time
Compiling about.markdown
  [      ] Checking cache: modified
  [   1ms] Total compile time
  [   0ms] Routing to about.html
Compiling css/default.css
  [   1ms] Total compile time
  [   0ms] Routing to css/default.css
Compiling css/syntax.css
  [   1ms] Total compile time
  [   0ms] Routing to css/syntax.css
Compiling index.markdown
  [      ] Checking cache: modified
  [  31ms] Total compile time
  [   0ms] Routing to index.html
```

So if you see any errors, **Don't Panic**. It'll turn out to have a simple explanation.)

You can also, at this point, run `./blog preview`, and then [check it out](http://0.0.0.0:8000) in your browser.

Pushing to Github
====================

Ok, so the blog's basically one stupid black-and-white single page (no problem, we'll add to that later). To get this basic example up and running, make sure you `git add` all the files you created.

In general, this will be a 4 step process:-

1. Edit posts
2. `hakyll build` to generate site contents inside _site
3. `cd _site` then `git add -i` and `git commit -m "new post etc"` and `git push origin master`. The blog is now live on Github Pages!
4. `cd ..` followed by another commit and push to check in your modified post(s)


----

For reference, my hakyll source lives [here](https://github.com/agam/hakyll-source) and the static website is generated [here](https://github.com/agam/agam.github.com)

*Continue on to [part 2](/posts/hakyll-multiple-posts-and-more.html)*
