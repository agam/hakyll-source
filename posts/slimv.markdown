---
title: SlimV and Vim as an equivalent to Emacs and Slime
date: 2013-08-06
---

SlimV and Vim
==========

I've switched between Emacs and Vim a few times over the last 15-odd years, before finally (?) settling on Vim. I've come to the realization, as many have before me, that for all the elegant awesomeness of Emacs Lisp,

> Vim is a better *text* editor, Emacs is good for everything else

Perhaps one day if [Guile](http://www.gnu.org/software/guile/) or [Emacsey](https://google-melange.appspot.com/gsoc/proposal/review/google/gsoc2013/shanecelis/1) deliver their full promise, I'll happily live inside a REPL forever.

Until then, it's just _much, much, much_ faster to do the equivalent *text* operations in Vim than in Emacs (yes, I mapped CapsLock to Control; yes, I replaced `M-` by `C-xC-m-`).

There were still a few Emacs-only things that haunted me (I outgrew the need to have a [web browser](http://emacs-w3m.namazu.org/) or an [IRC client](http://www.gnu.org/software/emacs/manual/html_mono/erc.html) in my editor environment, I now use Google Chrome for the former and BitchX/Irssi/Xchat for the latter. I also don't mind reading my [email](http://gmail.com) in the browser), such as [`org-mode`](http://orgmode.org/). Fortunately for me, I don't most of its features, and keeping a timestamped diary is something I was able to fix for myself with some shell scripting and vim shortcuts.

Recently, I decided to learn Common Lisp with as much of a newbie attitude as possible. And here I ran into a veritable wall of convention. _Of course, didn't I know, that Emacs + Slime is the one true way ?_

I dithered, was flustered and nearly reconsidered.

And then I discovered the awesomeness I was looking for, a replacement for Slime in Vim, [Slimv](http://www.vim.org/scripts/script.php?script_id=2531)!

[Here is a tutorial](http://kovisoft.bitbucket.org/tutorial.html) to get you started, but basically all I had to do was to install the plugin and the rest pretty much _just worked_.

There are quite a lot of nifty tricks here, but my most frequently used commands are:

* `,L`: that's a comma followed by L): compile current file
* `,D`: compile current form
* `,s`: lookup a short summary description of the keyword under the cursor
* `,c`: Open Slimv session (splits the window horizontally)

I was also new to `paredit mode`, which is pretty much necessary for making changes to heavily nested parantheses, and it has useful commands there too:

* `,W`: wrap an extra set of parentheses around the current form
* `,S`: it's opposite; remove _one_ set of parentheses from the current form
* `,<`, `,>`: move the parentheses under the cursor one form to the left or right

... and much more. So next time someone tells you how `Slime` is indispensable and hence Emacs is indispensable, throw Slimv in their face! Kudos to [the guy who built it](http://www.vim.org/account/profile.php?user_id=16470)!

