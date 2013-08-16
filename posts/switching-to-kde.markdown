---
title: Switching to KDE
date: 2013-08-14
---

Switching to KDE
================

I have been using [Xmonad](http://xmonad.org/) for almost a couple of years, mostly because I wanted a tiling window manager that would maximize screen space and allow fast window and desktop switching on my linux laptop.

Recently, I decided to go back to a full-fledged desktop environment again, and I (randomly (please, no "Gnome vs Kde" flamewar)) picked KDE. The last time I used it was maybe 8 years ago (!), and I was eager to see what I had been missing.

It seems to have gotten better in the same sense that all linux software has gotten better in the last several years (and the machine I'm running it on has gotten much faster too!), but I particularly liked the idea of [Activities](http://userbase.kde.org/Plasma#Activities), being somewhat orthogonal to the idea of multiple desktops, and I found it useful to add "work", "browsing", "writing" etc areas.

Minor tweaks
-----------

I had to change the screen rotation of one of my monitors at my desktop, but this was fairly straightforward: [System Settings] -> [Display & Monitor] -> [Size & Orientation]

I also always get rid of the useless Caps Lock: [System Settings] -> [Input Devices] -> [Keyboard]

There's one issue which I'm not quite sure about -- I encountered a `no d-bus daemon running` message, which I fixed by `export $(dbus-launch)`, and I haven't encountered it since, but I haven't read up enough to know if this requires some more setup.

I had an `xscreensaver` lock alias earlier, and I wanted something similar; I assigned `klock` to `/usr/lib/kde4/libexec/kscreenlocker --forcelock`

Finally, I need a way to setup easy terminal access. I setup `Meta+T` to run `konsole`, `Meta+R` to run `krunner` (which brings up a "quick run" box), and (I love this part) installed `yakuake` which I mapped to `` Meta+` ``.


Other switches considered: Firefox
-------------------------

I tried moving to Firefox for a while, but I really found it slower than Google Chrome. OK, I didn't personally benchmark it, but several content-heavy websites seemed to load slower.

Also, I had gotten used to certain workflows in Chrome (such as entering `amazon.com`, hitting `Tab` and then typing what I wanted to search within Amazon) which were no longer possible with Firefox, and I didn't want to take the productivity hit.

However, I installed the Android app, and activated Firefox Sync and everything worked pretty well. Honestly, I liked the mobile app better. But this is one of those all or nothing switches, since the "tab syncing" between desktop/laptop/mobile browsers is indispensable to me.

I will definitely consider this in the future again, especially if Firefox's rendering speed improves w.r.t. Chrome.

Other switches considered: Emacs
------------------

This is one of those eternal conflicts, as I mentioned in [a previous post](/posts/slimv.html). I keep wanting to switch to Emacs, but Vim always remains atleast an order of magnitude faster for me, for most common tasks, so I just can't do it.

As I see it, nothing which begins with `C-u` can ever be faster than the equivalent two-character command in Vim (in particular, `C-x z` is 10 times slower than just `.`).

Recently, I was discussing this with a few colleagues, and one of the things that was suggested was `Viper`-mode in Emacs as a halfway compromise.

I'll look into it, see what keystrokes are supported, and if my regular workflow is unaffected, this too might be a switch I'd be willing to make in the future.