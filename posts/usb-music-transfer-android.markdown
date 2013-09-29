---
title: Getting music onto an Android phone's external storage
date: 2013-09-29
---

Getting music onto an Android phone
==================================

I had bought a MicroSD card to go along with my Motorola Razr M, since it has a limited internal storage of 8G.

(That is to say, _limited_ by today's standards, where a singe Chrome tab can take up a few hundred MB. I remember when I was excited to find a computer with 8MB Ram since that meant I could play Quake on it. Anyway ...)

I assembled everything on my (linux) laptop in one folder, this should just be a copy-and-paste, drag-and-drop kind of thing, right ?

_Wrong_.

Instead I had to wade through a bunch of online forum posts, about mounting the phone on windows, on mac, configuring various settings.

When I plugged in the phone through USB, I got a notification saying the phone was connected but it didn't show up in Ubuntu's list of connected devices (and I know this works for other devices because my external hard drive shows up when I connect i
t).

Finally I found [this](http://www.mysolutions.it/mounting-your-mtp-androids-sd-card-on-ubuntu/), it assured me that _"Fortunately, it’s quite easy to get this working"_.

Of course, it was incomplete (yes, you need `sudo apt-get install mtpfs` but *also* `sudo apt-get install mtp-tools`)

```shell
sudo mkdir /media/MTPDevice
sudo chmod 775 /media/MTPDevice
sudo mtpfs -o allow_other /media/MTPDevice/
```

Finally, I saw

```shell
$ mtp-detect
libmtp version: 1.1.3

Listing raw device(s)
Device 0 (VID=22b8 and PID=2e51) is UNKNOWN.
Please report this VID/PID and the device model to the libmtp development team
   Found 1 device(s):
   22b8:2e51 @ bus 2, dev 9
Attempting to connect device(s)
PTP_ERROR_IO: failed to open session, trying again after resetting USB interface
LIBMTP libusb: Attempt to reset device
inep: usb_get_endpoint_status(): No such device
outep: usb_get_endpoint_status(): No such device
usb_clear_halt() on IN endpoint: No such device
usb_clear_halt() on OUT endpoint: No such device
usb_clear_halt() on INTERRUPT endpoint: No such device
usb_open(): No such device
LIBMTP PANIC: Could not init USB on second attempt
Unable to open raw device 0
OK.
```

Woo hoo. So much for that.

Then I came across [this](http://penzoditutto.blogspot.it/2012/12/android-mtp-devices-40-mount-scripts.html), which seemed more pragmatic, since it said "If you're using ubuntu (12.04 or 12.10) and you want to browse your Android 4.0+ device _you know how frustrating can be._" Yes I do.

But it didn't have anything fundamentally different.

So I just pulled out the USB cable and plugged it in again ("when all else fails, cycle power")

This time, it worked.

```shell
$ mtp-detect
libmtp version: 1.1.3

Listing raw device(s)
Device 0 (VID=22b8 and PID=2e51) is UNKNOWN.
Please report this VID/PID and the device model to the libmtp development team
   Found 1 device(s):
   22b8:2e51 @ bus 2, dev 11
Attempting to connect device(s)
Android device detected, assigning default bug flags
USB low-level info:
   Interface has a kernel driver attached.
   bcdUSB: 512
   bDeviceClass: 0
   bDeviceSubClass: 0
   bDeviceProtocol: 0
   idVendor: 22b8
   idProduct: 2e51
   IN endpoint maxpacket: 512 bytes
   OUT endpoint maxpacket: 512 bytes

< ... and many more pages ... >
```

While we're here, a clarification by way of digression: I am not ranting against MTP, just its usability. It is clearly (IMHO) better than the previous mass storage option, since it supports well-defined interfaces to specific file types, such as this one for JPEG files:

```shell
   3801: JPEG
      dc01: Storage ID UINT32 data type ANY 32BIT VALUE form READ ONLY
      dc02: Object Format UINT16 data type ANY 16BIT VALUE form READ ONLY
      dc03: Protection Status UINT16 data type ANY 16BIT VALUE form READ ONLY
      dc04: Object Size UINT64 data type READ ONLY
      dc07: Object File Name STRING data type GET/SET
      dc09: Date Modified STRING data type DATETIME FORM READ ONLY
      dc0b: Parent Object UINT32 data type ANY 32BIT VALUE form READ ONLY
      dc41: Persistant Unique Object Identifier UINT128 data type READ ONLY
      dc44: Name STRING data type READ ONLY
      dce0: Display Name STRING data type READ ONLY
      dc4e: Date Added STRING data type DATETIME FORM READ ONLY
      dc48: Description STRING data type READ ONLY
```

But wait a minute, what happened to the directory I created ?

```shell
$ ls -ld /media/MTPDevice/
ls: cannot access /media/MTPDevice/: Transport endpoint is not connected
```

Obviously I celebrated too soon. More trudging through posts. As an idea of how crazy this can seem, I found [this post](http://askubuntu.com/questions/159095/problems-connecting-android-ics-to-ubuntu-using-mtp) on [askubuntu](http://www.askubuntu.com) which said:

"Please note the Terence Egan Blog where you took the instructions from is a copy of an OMG Ubuntu article. He has missed an important step *to restart your PC before running the Echo commands* I suggest you try and reinstall from the original OMG Ubuntu source. Click on this link" (emphasis mine, link omitted).

Yes, that's right, _N00b_. You forgot to restart.

(In case you're wondering how that story ends,
"Oh my god!!! I did not know that. Will do this asap. – ubuntico Jul 3 '12 at 16:40
It worked this way. *I connect the mobile and them immediately (under 1s after connection) I have to start command android-connect. Otherwise, the system will try to mount the mobile and after that I cannot use fuse to mount it.* It the same with you? – ubuntico Jul 3 '12 at 17:08")

Maybe I'm expecting too much, but I would not refer to this tenuous solution as _"it worked"_.

Hmm, it looks like I skipped a step. I had to modify `/etc/udev/rules.d/51-android.rules` to add the right `SUBSYSTEM...` rule, and then `sudo service udev restart`.

Nope, no luck. I can't access, mount, unmount or delete.

```shell
$ fusermount -u /media/MTPDevice 
fusermount: entry for /media/MTPDevice not found in /etc/mtab
$ sudo mtpfs -o allow_other /media/MTPDevice/
fuse: bad mount point `/media/MTPDevice/': Transport endpoint is not connected
$ sudo rmdir /media/MTPDevice
rmdir: failed to remove `/media/MTPDevice': Device or resource busy
```

But wait! All is not lost! We can use the `adb` tool to interact directly with the android filesystem!

```shell
$ ./adb push /media/My\ Book/Music/Amazon\ MP3/Eminem/ /sdcard/Music/
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/17 - Untitled [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/17 - Untitled [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/16 - You're Never Over [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/16 - You're Never Over [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/15 - Love The Way You Lie [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/15 - Love The Way You Lie [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/14 - Almost Famous [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/14 - Almost Famous [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/13 - So Bad [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/13 - So Bad [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/12 - 25 To Life [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/12 - 25 To Life [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/11 - Cinderella Man [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/11 - Cinderella Man [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/10 - Space Bound [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/10 - Space Bound [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/09 - No Love [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/09 - No Love [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/08 - Seduction [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/08 - Seduction [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/07 - Not Afraid [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/07 - Not Afraid [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/06 - Going Through Changes [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/06 - Going Through Changes [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/05 - W.T.P. [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/05 - W.T.P. [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/04 - Won't Back Down [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/04 - Won't Back Down [Explicit].mp3
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/03 - On Fire [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/03 - On Fire [Explicit].mp3                                                
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/02 - Talkin' 2 Myself [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/02 - Talkin' 2 Myself [Explicit].mp3                              
push: /media/My Book/Music/Amazon MP3/Eminem/Recovery [Explicit]/01 - Cold Wind Blows [Explicit].mp3 -> /sdcard/Music/Recovery [Explicit]/01 - Cold Wind Blows [Explicit].mp3                                
17 files pushed. 0 files skipped.                                                                                                                                                                            
3624 KB/s (150604367 bytes in 40.580s)                                                                          
```

and verify it after running `adb shell`

```shell
shell@scorpion_mini:/ $ ls sdcard/Music/                                       
Recovery [Explicit]
```

So yeah. It works. And it's a _magical_ experience.