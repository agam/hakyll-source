---
title: Hakyll: multiple posts and more
date: 23 Dec 2012
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

~~~
        <h1>$$title$$</h1>
	<br>
	<h2>$$date$$</h2>
	<br>

        $$body$$
~~~

Ok, `ghc --make blog.hs && ./blog preview` confirms that all is well. There's still the problem that the 

Analytics and Comments
-------------------------

I'll be brief here, since you probably already know this, and this isn't relevant to hakyll in anyway. There are many commenting systems out there, I found [Disqus](http://www.disqus.com) to be really quick to set up.

Enter your username, password, site url, and you'll be shown a list of hosting platforms; just select *Universal Code* from the list, then copy-paste the javascript into the html footer of your post template. Done. Your posts now have comments!

Similarly, if you want to track site visits, [Google Analytics](www.google.com/analytics/) is a quick solution. Sign up for a new account, enter the website name, and then get your "tracking code", which is a bit of javascript you (again) tack on to the end of each post's html.



