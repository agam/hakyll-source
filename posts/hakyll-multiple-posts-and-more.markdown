---
title: Hakyll: multiple posts and more
date: 2013-01-04
---

Handling multiple posts, and more
========================================

At the moment, my blog is basically a single page. This is boring, so let's expand it to handle multiple pages. Also, each page should be templatized in turn, so that we can add a footer to handle analytics, comments, etc.

Multiple posts
--------------------

I'll do this step by step. First, I'll ignore the index page and just add support for the posts. So `blog.hs` gets a new "match" rule.

```haskell
    match "posts/*" $ do
        route     $ setExtension "html"
        compile   $ pageCompiler
            >>> applyTemplateCompiler "templates/post.html"
            >>> relativizeUrlsCompiler
```

I modified `index.markdown` to explicitly point to the two posts for now (i.e. this one and the previous one).

Also, I created `templates/post.html`, which has some basic boilerplate difference from the template used to serve the index page :-

```html
        <h1>$$title$$</h1>
	<br>
	<h2>$$date$$</h2>
	<br>

        $$body$$
```

Ok, `ghc --make blog.hs && ./blog preview` confirms that all is well.

Analytics and Comments
-------------------------

I'll be brief here, since you probably already know this, and this isn't relevant to hakyll in anyway. There are many commenting systems out there, I found [Disqus](http://www.disqus.com) to be really quick to set up.

Enter your username, password, site url, and you'll be shown a list of hosting platforms; just select *Universal Code* from the list, then copy-paste the javascript into the html footer of your post template. Done. Your posts now have comments!

Similarly, if you want to track site visits, [Google Analytics](www.google.com/analytics/) is a quick solution. Sign up for a new account, enter the website name, and then get your "tracking code", which is a bit of javascript you (again) tack on to the end of each post's html.

Showing a list of posts
-------------------------

At a minimum, we'd like to show the last few posts on the index page, and provide a link to the list of *all* posts.

Let's do the second item first. To do this, we'll create a pseudo-page that will be defined based on the list of posts found in the `posts/` subdirectory.

(BTW this is heavily ~~inspired by~~ copy-pasted from [this hakyll example](https://github.com/jaspervdj/hakyll-examples/blob/master/feedblog/hakyll.hs))

Since we want to have a 'list of posts' on the index page as well, this common functionality can be abstracted out.

```haskell
addPostList :: Compiler (Page String, [Page String]) (Page String)
addPostList = setFieldA "posts" $
    arr (reverse . chronological)
        >>> require "templates/postitem.html" (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody
```

Now create a rudimentary html fragment that will hold the 'post summary'

```html
<li>
   <a href="$ url $">$ title $</a> - <em>$ date $</em>
</li>
```

Finally, to tie it together, add a match for `posts.html`, which will be the entry point to show the list of all posts.

```haskell
    match "posts.html" $ route idRoute 
    create "posts.html" $ constA mempty
        >>> arr (setField "title" "All posts")
        >>> requireAllA "posts/*" addPostList
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler
```

Showing a subset of all posts on the index page
--------------------------------------------------

Initially, I had some trouble getting this to work, for some reason the ```match "posts/*"``` wasn't working, and I commented out the ```match "index.html"``` and retained the ```index.markdown``` that I had.

Turned out to be another ommission on my part, I had to replace

```haskell
	match "index.html" $ do
	create "index.html" $ constA mempty
```

with

```haskell
	match "index.html" $ route idRoute
	create "index.html" $ constA mempty
```

... and then it works!

Getting the list of the last (say) 3 posts is achieved by having a line similar to the one in the handler for ```posts.html```, except instead of just

```haskell
	>>> requireAllA "posts/*" addPostList
```

we now have

```haskell
        >>> requireAllA "posts/*" (id *** arr (take 3 . reverse . chronological) >>> addPostList)
```

CSS-ifying
-----------

You probably know more about this than me, but if you don't want a black-and white, crammed together bunch of text, you probably want atleast a couple of css rules for your headers and the body text etc. I cobbled together mine based on some random examples I found online, pick yours as you see fit.


