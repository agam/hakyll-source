---
title: Comparing "Hello World" in Go
date: 12 Mar 2013
---

Comparing "Hello World" in Go
=============================

Since I looked at printing "Hello World" [in C and Haskell earlier](/posts/hello-world-comparison.html), I thought I would look at what *[Go](http://golang.org/)* does diferently.

Source program
--------------

So we start with this

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World")
}
```

Binary info
-------------

The generated binary is large, like haskell, since (like haskell) it has a runtime linked in

```shell
$ ls -lh | grep '\-x\-'
-rwxr-x--- 1 agam eng 1.1M Mar 10 17:27 haskellhelloworld
-rwxr-x--- 1 agam eng 8.8K Dec 14 16:10 helloworldcpp
-rwxr-x--- 1 agam eng 1.3M Mar 12 18:07 helloworldgo
```

It does define an intermediate number of symbols though:

```shell
$ nm helloworldgo | wc -l
1748
```

Unlike both C++ and Haskell though (and this is really impressive) the Go binary is statically linked. So presumably I can copy it to a different location and expect it to run without worry too much about the environment (although I don't know if this is true for all supported libraries (i.e. there might be certain Go libraries that don't allow static linking)).

Object code
-----------

To see the generated assembly, run the following (the `sed` here is to get rid of the filename + linenumber that shows up on every line).

```shell
$ go build -gcflags=-S helloworld.go  | sed 's/([^ ]*)//' > helloworldgo.s
```

I've [saved the output in one piece](https://gist.github.com/agam/5148575) if you want to look at it.

The assembly format here looks very different from what we saw before; that's because it's in the [Plan 9 assembler](http://doc.cat-v.org/plan_9/4th_edition/papers/asm) format, and it's a bit confusing since it introduces new pseudo-instructions and pseudo-registers.

Luckily, the generated assembly is somewhat annotated so it is much easier to follow along.

```nasm
--- prog list "main" ---
0000  TEXT    main+0(SB),$72-0
0001  LEAQ    autotmp_0002+-16(SP),DI
0002  MOVQ    $0,AX
0003  STOSQ   ,
0004  STOSQ   ,
```

I was confused by the `autotmp_000x` all over the code, until I looked at the [corresponding runtime code](http://golang.org/src/cmd/gc/gen.c) and realized these were unique names for temporary variables in the original code.

```nasm
0005  LEAQ    autotmp_0002+-16(SP),BX
0006  MOVL    $1,autotmp_0000+-24(SP)
0007  MOVL    $1,autotmp_0000+-20(SP)
0008  MOVQ    BX,autotmp_0000+-32(SP)
0009  MOVQ    $type.string+0(SB),(SP)
```

Raw data, such as the string "Hello, World" here, [have to be converted](http://golang.org/src/pkg/runtime/iface.c) to types within the program.

```nasm
0010  LEAQ    go.string."Hello, World"+0(SB),SI
0011  LEAQ    8(SP),DI
0012  MOVSQ   ,
0013  MOVSQ   ,
0014  CALL    ,runtime.convT2E+0(SB)
0015  LEAQ    24(SP),SI
0016  LEAQ    autotmp_0000+-32(SP),DI
0017  MOVQ    (DI),DI
0018  MOVSQ   ,
0019  MOVSQ   ,
```

Not sure here ... looks like the string is being copied, as an argument to ```fmt.Println``` ?

```nasm
0020  LEAQ    (SP),BX
0021  MOVQ    autotmp_0000+-32(SP),BP
0022  MOVQ    BP,(BX)
0023  MOVL    autotmp_0000+-24(SP),BP
0024  MOVL    BP,8(BX)
0025  MOVL    autotmp_0000+-20(SP),BP
0026  MOVL    BP,12(BX)
0027  CALL    ,fmt.Println+0(SB)
0028  RET     ,
```

General runtime initialization ... including a call to ```fmt.init``` to initialize static data in the ```fmt``` package.

```nasm
--- prog list "init" ---
0029  TEXT    init+0(SB),$0-0
0030  MOVB    initdone·+0(SB),AX
0031  MOVB    AX,BX
0032  CMPB    BX,$0
0033  JEQ     ,39
0034  MOVB    AX,BX
0035  CMPB    BX,$2
0036  JNE     ,38
0037  RET     ,
0038  CALL    ,runtime.throwinit+0(SB)
0039  MOVB    $1,initdone·+0(SB)
0040  CALL    ,fmt.init+0(SB)
0041  MOVB    $2,initdone·+0(SB)
0042  RET     ,
```

The data section ...

```
--- prog list "<S>" ---
0043  DATA    go.string."Hello, World"+0(SB)/8,$go.string."Hello, World"+12(SB)
0043  DATA    go.string."Hello, World"+8(SB)/4,$12
0043  DATA    go.string."Hello, World"+12(SB)/8,$"Hello, W"
0043  DATA    go.string."Hello, World"+20(SB)/4,$"orld"
0043  DATA    go.string."Hello, World"+24(SB)/1,$0
0043  GLOBL   go.string."Hello, World"+0(SB),10,$32
```

Omitted most of the rest of the data section, althought it has some weird stuff that I'd like to dig into later, such as 

```nasm
...
...
...
0043  DATA    go.string."func(*uint8, string) interface {}"+0(SB)/8,$go.string."func(*uint8, string) interface {}"+12(SB)
0043  DATA    go.string."func(*uint8, string) interface {}"+8(SB)/4,$33
0043  DATA    go.string."func(*uint8, string) interface {}"+12(SB)/8,$"func(*ui"
0043  DATA    go.string."func(*uint8, string) interface {}"+20(SB)/8,$"nt8, str"
0043  DATA    go.string."func(*uint8, string) interface {}"+28(SB)/8,$"ing) int"
0043  DATA    go.string."func(*uint8, string) interface {}"+36(SB)/8,$"erface {"
0043  DATA    go.string."func(*uint8, string) interface {}"+44(SB)/1,$"}"
0043  DATA    go.string."func(*uint8, string) interface {}"+45(SB)/1,$0
0043  GLOBL   go.string."func(*uint8, string) interface {}"+0(SB),10,$48
...
...
...
0043  END     ,
```

(What exactly is going on here ? Perhaps encoding strings to use for runtime error reporting ?)

Running time
------------

Again, running a string output program for time comparison is stupid, but I can't help doing this stupid thing. So ...

```shell
$ time (while ((n++ < 100)); do ./helloworldgo; done)

real	0m0.567s
user	0m0.196s
sys	0m0.132s
```

