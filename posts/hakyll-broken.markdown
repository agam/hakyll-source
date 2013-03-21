---
title: Hakyll broken ?
date: 2013-03-20
---

Hakyll transition
=================

I noticed that the dates in my blog were all wrong, and now the blog
doesn't build.

```shell
ghc --make blog.hs
[1 of 1] Compiling Main             ( blog.hs, blog.o )

blog.hs:27:12:
    Not in scope: `list'
    Perhaps you meant `last' (imported from Prelude)

blog.hs:29:21: Not in scope: `pageCompiler'

blog.hs:30:17: Not in scope: `applyTemplateCompiler'

blog.hs:31:17: Not in scope: `relativizeUrlsCompiler'

blog.hs:34:27:
    Not in scope: `constA'
    Perhaps you meant `const' (imported from Prelude)

blog.hs:35:18: Not in scope: `setField'

blog.hs:36:13: Not in scope: `requireAllA'

blog.hs:37:13: Not in scope: `applyTemplateCompiler'

blog.hs:38:13: Not in scope: `applyTemplateCompiler'

blog.hs:39:13: Not in scope: `relativizeUrlsCompiler'

blog.hs:43:21: Not in scope: `pageCompiler'

blog.hs:44:17: Not in scope: `applyTemplateCompiler'

blog.hs:45:17: Not in scope: `applyTemplateCompiler'

blog.hs:46:17: Not in scope: `relativizeUrlsCompiler'
```

The price to pay for using a system in flux ... oh well, time to read up on
the [hakyll
transition](http://jaspervdj.be/hakyll/tutorials/04-compilers.html) from v3 to v4.

Alright, that isn't good enough ... need some 'patterns' to work with.
Luckily, I found [another Hakyll blog](http://wmasson.com/) that made the jump, and shameless
plagiarized. (So thank you, ```wmasson```!)

Well, I didn't even plagiarize well. I used tabs instead of spaces at one
point and stared at a ```parse error on input `='``` error message for
_some time_.

I spent some more time staring at

```
blog.hs:39:47:
    Couldn't match expected type `Item String'
                with actual type `[Item String]'
    Expected type: [Item String] -> [Item String]
      Actual type: [Item String] -> [[Item String]]
    In the second argument of `(.)', namely `recentFirst'
    In the second argument of `($)', namely `take 3 . recentFirst'
```

... and then I realized that the signature of ```postList``` was wrong and should have its second argument as ```([Item String] -> Compiler [Item String])``` instead of ```([Item String] -> [Item String])```.
Had to change ```prep <$> loadAll pattern``` to ```prep =<< loadAll pattern``` to accomodate this change.

Somehow the type signature of the main page function didn't match, so I modified the ```postList``` function to take a ```listmodifier```; this way I could pass in ```id``` for the list of all posts and ```(take 3)``` for the main page.

I also had to change the date format from ```%d %m %Y``` to ```%Y-%m-%d```, since I was getting an

```
[ERROR] Hakyll.Web.Template.Context.getItemUTC: could not parse time for ...
```

error message, looking at the [source](https://github.com/jaspervdj/hakyll/blob/master/src/Hakyll/Web/Template/Context.hs#L200) I found that only a few formats were supported.

Finally, right at the end, I clobbered the git submodule in my output directory when I did a ```./blog rebuild```. So to bring it back, I had to

```shell
$ rm -f .gitmodules
$ ./blog clean
Removing _site...
Removing _cache...
Removing _cache/tmp...
$ git rm -r _site
rm '_site'
$ git submodule add --force git@github.com:agam/agam.github.com.git _site
Reactivating local git directory for submodule '_site'.
$ ./blog build
```

So ... no outward change in appearance, but a lot of time wasted, and all because I was bold enough to run ```cabal update```.

Yes, I know. Sad.

But it works! (atleast the chronological sorting works again).


_Update:_ Just for fun, I tweaked the CSS of the page a bit, to make it a little less bland.

