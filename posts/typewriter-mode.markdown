---
title: Using Typewriter mode, ALWAYS
date: 2013-11-06
---

Using Typewriter mode, ALWAYS
==============================

I used to have two giant monitors to work with, and reduced them to one since I
found myself frequently moving my neck from side to side.

I got rid of one of them, and felt much better after that -- but now I was still
moving my neck up and down. When editing large source files (wait, why are these
files large to begin with ? That's a different conversation!), you do end up
tracking the cursor on each find, on each scroll.

The solution is obvious -- as far as possible, keep the horizontal location of
the cursor fixed.

I'm sure what the Emacs equivalent of this is, but if you use the One True
Editor, try typing `:help scrolloff` right now; you should see this:

```
						*'scrolloff'* *'so'*
'scrolloff' 'so'	number	(default 0)
			global
			{not in Vi}
	Minimal number of screen lines to keep above and below the cursor.
	This will make some context visible around where you are working.  If
	you set it to a very large value (999) the cursor line will always be
	in the middle of the window (except at the start or end of the file or
	when long lines wrap).
	For scrolling horizontally see 'sidescrolloff'.
	NOTE: This option is set to 0 when 'compatible' is set.
```

So you can add this to your `.vimrc` later, but try it out right now. Type 

```
:set scrolloff=999
```

... and scroll around a bit.

Enjoy.

