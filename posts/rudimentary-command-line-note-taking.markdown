---
title: Rudimentary note taking on the command line
date: 2013-07-24
---

Taking notes on the command line
===

Everyone has their own pet setup; here's mine. Its just a bunch of text files, shared on Dropbox.

I have a bash alias to make a directory if required, create the file, and open it in Vim.

Within the file, I use markdown for text, and a few additional conventions to make it easier to search through them.

I use one file per date, with the name being something like `~/notes/2013/07/24`.

The following one-liner in my `.bashrc` accomplishes this:

```shell
# Bring up the day's notes
function diary() {
  year=`date "+%Y"`
  month=`date "+%m"`
  day=`date "+%d"`
  diarydir=~/Dropbox/personalnotes/$year/$month
  if [[ ! -d "$diarydir" ]]; then
    mkdir -p "$diarydir"
  fi
  vi $diarydir/$day
}
```

I also use some additional _metadata_ within it, such as adding '@14:45' to indicate a timestamp before a paragraph, and '#category' to mark off sections (I use '##category' to denote one-line or one paragraph sections, otherwise all text is assumed to belong to the last declared section).

For convenience, I defined the following mapping in my ```.vimrc``` that inserts the timestamp when required:

```shell
nmap <C-c><C-t> o@<C-R>=strftime("%H:%M")<CR><CR><CR>
```

I'll cover the retrieval part of this in a separate post. If you don't have any note taking system yet, and don't want to go to the extent of _blogging_ every little thing you want to note down, and find it a bit of a hassle to open up Evernote or something similar to jot something down, you might like to try this quick and simple text-based solution!

