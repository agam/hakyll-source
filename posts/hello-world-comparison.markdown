---
title: Comparing "Hello World" in C++ and Haskell
date: 10 Mar 2013
---

"Hello World" in C++ and Haskell
================================

I feel I've totally forgotten all about assembly, and I was curious anyway about how Haskell differed fundamentally in its basic code generation, so I decided to contrast a basic example against C++.

The choice of C++ here is arbitrary; it just happens to be something I've used most often, and pretty much all the time for the last decade or so. If it ends up being interesting, I can add similar comparisons for other languages. 

Source Programs
----------------

The C++ version:

```C
#include <iostream>

int main(int argc, char** argv) {
  std::cout << "Hello world\n\n";
}
```

The Haskell version:

```Haskell
main = putStrLn "Hello World"
```

Some high-level differences:
----------------------------

Difference in size of generated binary:

```
-rwxr-x--- 1 agam eng 8.8K Dec 14 16:10 cpphelloworld
-rwxr-x--- 1 agam eng 1.1M Dec 14 16:16 haskellhelloworld
```

Difference in number of symbols defined:

```
nm cpphelloworld | wc -l
41
nm haskellhelloworld | wc -l
6578
```

Differences in libraries linked in :-

```
$ ldd cpphelloworld
	linux-vdso.so.1 =>  (0x00007fffcb5a7000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007ffe35064000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007ffe34ca5000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007ffe349a8000)
	/lib64/ld-linux-x86-64.so.2 (0x00007ffe35381000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007ffe34792000)

$ ldd haskellhelloworld
	linux-vdso.so.1 =>  (0x00007fff681b9000)
	libgmp.so.10 => /usr/lib/x86_64-linux-gnu/libgmp.so.10 (0x00007f427e124000)
	libffi.so.6 => /usr/lib/x86_64-linux-gnu/libffi.so.6 (0x00007f427df1c000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f427dc1f000)
	librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f427da17000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f427d813000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f427d453000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f427d236000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f427e3af000)
```


C++ Object Code
------------

The C++ version:

Filename, and a static declaration of ```std::__ioinit``` defined in ```iostream```.

```nasm
	.file	"helloworld.cpp"
	.local	_ZStL8__ioinit
	.comm	_ZStL8__ioinit,1,1
```

Read-only data, containing the string used in our program.

```nasm
	.section	.rodata
.LC0:
	.string	"Hello world\n\n"
```

Beginning of the '```main```' function, which is globally visible.

```nasm
	.text
	.globl	main
	.type	main, @function
```

The C++ code has a lot of these ```cfi_``` declarations, which is Call Frame Information for the [DWARF debugging format](http://www.logix.cz/michal/devel/gas-cfi/dwarf-2.0.0.pdf)

```nasm
main:
.LFB966:
	.cfi_startproc
```

Start new frame, Store old stack pointer.

```nasm
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
```

Create space for local variables on the stack.
Copy the value of (empty) EDI and RSI onto this created space.
Copy the string declared above into ESI.
Store the address of the ```std::cout``` object into EDI.
Reset EAX to 0.
Call the std::basic_ostream<std::char_traits> operator<<()

```nasm
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	movl	$.LC0, %esi
	movl	$_ZSt4cout, %edi
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
```

This part is not particular to the specific program here; gcc creates a ```static_initialization_and_destruction``` section for each translation unit that needs any static constructors to be called.

```nasm
.LFE966:
	.size	main, .-main
	.type	_Z41__static_initialization_and_destruction_0ii, @function
_Z41__static_initialization_and_destruction_0ii:
.LFB970:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	cmpl	$1, -4(%rbp)
	jne	.L2
	cmpl	$65535, -8(%rbp)
	jne	.L2
	movl	$_ZStL8__ioinit, %edi
	call	_ZNSt8ios_base4InitC1Ev
	movl	$_ZNSt8ios_base4InitD1Ev, %eax
	movl	$__dso_handle, %edx
	movl	$_ZStL8__ioinit, %esi
	movq	%rax, %rdi
	call	__cxa_atexit
.L2:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
```

I'm not sure _wtf_ is going on here. When it calls the static initialization function, 1 and 65535 are passed as arguments. Then within the function, it verifies that it did actually get these two arguments, and only if they were passed in, it calls the static constructor ```ios_base::init```

```nasm
.LFE970:
	.size	_Z41__static_initialization_and_destruction_0ii, .-_Z41__static_initialization_and_destruction_0ii
	.type	_GLOBAL__sub_I_main, @function
_GLOBAL__sub_I_main:
.LFB971:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$65535, %esi
	movl	$1, %edi
	call	_Z41__static_initialization_and_destruction_0ii
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE971:
	.size	_GLOBAL__sub_I_main, .-_GLOBAL__sub_I_main
	.section	.ctors,"aw",@progbits
	.align 8
	.quad	_GLOBAL__sub_I_main
```

Omitted a bunch of library references that looked like 

```nasm
	.weakref	_ZL22__gthrw_pthread_createPmPK14pthread_attr_tPFPvS3_ES3_,pthread_create
```


Haskell core
---------------------

Haskell code generation is **significantly** different, so we'll look at generated [_core_](http://www.haskell.org/haskellwiki/Performance/GHC#Looking_at_the_Core) code first.

The best way for this is to use the ```ghc-core``` package.

```shell
$ cabal install ghc-core
$ ~/.cabal/bin/ghc-core --no-cast --no-asm haskellhelloworld.hs
```

I've removed the _attributes_ of functions, which look something like

```haskell
[GblId,
 Unf=Unf{Src=<vanilla>, TopLvl=True, Arity=0, Value=False,
         ConLike=False, Cheap=False, Expandable=False,
         Guidance=IF_ARGS [] 60 0}]
```

The cleaned up core looks like this:


```haskell
main2 :: [Char]
main2 = unpackCString# "Hello World"
```

The code seemse full of a lot of ```#```s, these are [primitive types](http://www.haskell.org/ghc/docs/latest/html/users_guide/primitives.html). The 'raw' string is made available as a different type to the program we wrote. Ghci is a good way to explore the type relationships here.

```haskell
Prelude> :t "Hello world"
"Hello world" :: [Char]
Prelude> :t putStrLn
putStrLn :: String -> IO ()

Prelude> :browse GHC.CString
...
... (other functions)
...
GHC.CString.unpackCString# :: GHC.Prim.Addr# -> [Char]
```

Continuing with our exploration of the core, ```main1``` is defined as a lambda function that effectively performs a```return``` on the value returned by ```Handle.Text.hPutStr2```

```haskell
main1
  :: State# RealWorld
     -> (# State# RealWorld, () #)
main1 =
  \ (eta_B1 :: State# RealWorld) ->
    Handle.Text.hPutStr2
      Handle.FD.stdout main2 True eta_B1
```

Once again, ghci to the rescue:

```haskell
Prelude> :m GHC.IO.Handle.Text
Prelude GHC.IO.Handle.Text> :t hPutStrLn
hPutStr :: GHC.IO.Handle.Types.Handle -> String -> IO ()
Prelude GHC.IO.Handle.Text> :m GHC.IO.Handle.FD
Prelude GHC.IO.Handle.FD> :t stdout
stdout :: GHC.IO.Handle.Types.Handle
```

Also, internally in [the source for this module](http://hackage.haskell.org/packages/archive/base/4.3.1.0/doc/html/src/GHC-IO-Handle-Text.html), ```hPutStrLn``` is implemented in terms of ```hPutStr'```, which has the type signature 

```haskell
hPutStr' :: Handle -> String -> Bool -> IO ()
```

Moving on, a ```main``` is defined but never used (perhaps just for correspondence with the user program?). Anywya, that is followed by a ```main3``` which actually runs the code. 


```
main :: IO ()
main =
  main1
  

main3
  :: State# RealWorld
     -> (# State# RealWorld, () #)
main3 =
  \ (eta_X9 :: State# RealWorld) ->
    runMainIO1
      @ ()
      (main1
       )
      eta_X9

:main :: IO ()
:main =
  main3
```

Again, internally, the comments for ```runMainIO``` in the [corresponding source file](http://hackage.haskell.org/packages/archive/base/3.0.1.0/doc/html/src/GHC-TopHandler.html) say:

```haskell
-- | 'runMainIO' is wrapped around 'Main.main' (or whatever main is
-- called in the program).  It catches otherwise uncaught exceptions,
-- and also flushes stdout\/stderr before exiting.
runMainIO :: IO a -> IO a
runMainIO main = (do a <- main; cleanUp; return a) `catchException` topHandler
```

Alright .... we're done with the core, and can look at the assembly, in full now.

Haskell object code
-------------------


As mentioned earlier, the object code here hardly corresponds to our one-line program, but we can read it (sort of !) since we know the core. First off is a declaratoin for the 'real' and 'dummy' ```main``` methods.

```nasm
.data
	.align 8
.align 1
.globl __stginit_Main
.type __stginit_Main, @object
__stginit_Main:
.globl __stginit_ZCMain
.type __stginit_ZCMain, @object
__stginit_ZCMain:
.section .data
	.align 8
.align 1
```

It is common in generated assembly to see functions wrapped in closures. So there will typically be 'info' for the function, a 'closure' for it, and when needed to be called, a 'jump' to it.


```nasm
sfB_srt:
	.quad	ghczmprim_GHCziCString_unpackCStringzh_closure

.data
	.align 8
.align 1
sfB_closure:
	.quad	sfB_info
	.quad	0
	.quad	0
	.quad	0
```

BTW I wanted to get the "official" line on this, so I went to the [haskell wiki](http://hackage.haskell.org/trac/ghc/wiki/Commentary/Compiler/GeneratedCode) and found this:

```
The goal of the STG machine is to reduce the current expression to a value.

When it has done so, it:

Stores a tagged pointer to evaluated closure in the STG register R1
Jumps to the entry code of the info table pointed to by the value at the top
of the STG stack
This may also be called the info table of the continuation of the expression
The continuation code is responsible for popping its info pointer (and stack-
allocated free variables, if any) from the stack before returning.

Arguments are passed on the stack, and are popped by the callee. Upon a
jump to the entry code for a function, there are always precisely as many
arguments on the stack as the (statically known) arity of that function,
and those arguments will be followed by the info pointer of a continuation.
```

Moving on, this (```cf0_str```) is our output string, declared byte-by-byte.

```nasm
.section .rodata
	.align 8
.align 1
cfO_str:
	.byte	72
	.byte	101
	.byte	108
	.byte	108
	.byte	111
	.byte	32
	.byte	87
	.byte	111
	.byte	114
	.byte	108
	.byte	100
	.byte	0
.text
	.align 8
	.long	sfB_srt-(sfB_info)+0
	.long	0
	.quad	0
	.quad	4294967318
```

I was totally stumped by ```newCAF``` and ```CAF_BLACKHOLE_info``` here, so I had to Google around to find [some helpful info on it](http://mainisusuallyafunction.blogspot.com/2011/10/thunks-and-lazy-blackholes-introduction.html).This in turn led me to the [GHC runtime code](https://github.com/ghc/ghc/blob/master/rts/sm/Storage.c#L262) which says

```

   The entry code for every CAF does the following:
     
      - builds a CAF_BLACKHOLE in the heap

      - calls newCaf, which atomically updates the CAF with
        IND_STATIC pointing to the CAF_BLACKHOLE

      - if newCaf returns zero, it re-enters the CAF (see Note [atomic
        CAF entry])

      - pushes an update frame pointing to the CAF_BLACKHOLE

   Why do we build an BLACKHOLE in the heap rather than just updating
   the thunk directly?  It's so that we only need one kind of update
   frame - otherwise we'd need a static version of the update frame
   too, and various other parts of the RTS that deal with update
   frames would also need special cases for static update frames.

   newCaf() does the following:
       
      - it updates the CAF with an IND_STATIC pointing to the
        CAF_BLACKHOLE, atomically.

      - it puts the CAF on the oldest generation's mutable list.
        This is so that we treat the CAF as a root when collecting
        younger generations.

```

If you want to know more about CAFs (Constant Applicative Forms), see [this wiki page](http://www.haskell.org/haskellwiki/Constant_applicative_form)

So, moving on, what follows is book-keeping (ok, I just really want to skip over these 20 lines)

```haskell
sfB_info:
.LcfS:
	leaq -16(%rbp),%rax
	cmpq %r15,%rax
	jb .LcfU
	addq $16,%r12
	cmpq 144(%r13),%r12
	ja .LcfW
	movq $stg_CAF_BLACKHOLE_info,-8(%r12)
	movq 160(%r13),%rax
	movq %rax,0(%r12)
	movq %r13,%rdi
	movq %rbx,%rsi
	leaq -8(%r12),%rdx
	subq $8,%rsp
	movl $0,%eax
	call newCAF
	addq $8,%rsp
	testq %rax,%rax
	je .LcfX
```

Closures in action! Here we see the steps: Move the frame info into place, setup the function we want to call (here ```GHC.String.unpackCString```) and its arguments (```cfo_str``` from above) and then ```jmp``` to an evaluating function (here ```stg_ap_n_fast```).

```haskell
.LcfY:
	movq $stg_bh_upd_frame_info,-16(%rbp)
	leaq -8(%r12),%rax
	movq %rax,-8(%rbp)
	movl $ghczmprim_GHCziCString_unpackCStringzh_closure,%ebx
	movl $cfO_str,%r14d
	addq $-16,%rbp
	jmp stg_ap_n_fast
.LcfW:
	movq $16,192(%r13)
.LcfU:
	jmp *-16(%r13)
.LcfX:
	jmp *(%rbx)
	.size sfB_info, .-sfB_info
```

Setting up the ```Main_main_closure```, which combines ```base.SystemIO.putStrLn``` and ```sfB_closure```(above).

```haskell
.section .data
	.align 8
.align 1
Main_main_srt:
	.quad	base_SystemziIO_putStrLn_closure
	.quad	sfB_closure
.data
	.align 8
.align 1
.globl Main_main_closure
.type Main_main_closure, @object
Main_main_closure:
	.quad	Main_main_info
	.quad	0
	.quad	0
	.quad	0
.text
	.align 8
	.long	Main_main_srt-(Main_main_info)+0
	.long	0
	.quad	0
	.quad	12884901910
.globl Main_main_info
.type Main_main_info, @object
```

Moving on ... bookkeeping for the main function similar for the functions above

```haskell
Main_main_info:
.Lcgf:
	leaq -16(%rbp),%rax
	cmpq %r15,%rax
	jb .Lcgh
	addq $16,%r12
	cmpq 144(%r13),%r12
	ja .Lcgj
	movq $stg_CAF_BLACKHOLE_info,-8(%r12)
	movq 160(%r13),%rax
	movq %rax,0(%r12)
	movq %r13,%rdi
	movq %rbx,%rsi
	leaq -8(%r12),%rdx
	subq $8,%rsp
	movl $0,%eax
	call newCAF
	addq $8,%rsp
	testq %rax,%rax
	je .Lcgk
```

Running the ```main``` closure ... this is also a demonstration of how functions are connected (one closure is an argument for the other closure)

```haskell
.Lcgl:
	movq $stg_bh_upd_frame_info,-16(%rbp)
	leaq -8(%r12),%rax
	movq %rax,-8(%rbp)
	movl $base_SystemziIO_putStrLn_closure,%ebx
	movl $sfB_closure,%r14d
	addq $-16,%rbp
	jmp stg_ap_p_fast
.Lcgj:
	movq $16,192(%r13)
.Lcgh:
	jmp *-16(%r13)
.Lcgk:
	jmp *(%rbx)
	.size Main_main_info, .-Main_main_info
.section .data
	.align 8
.align 1
```

Ok, our last round of setting up the 'running main function' and then its associated book-keeping

```haskell
ZCMain_main_srt:
	.quad	base_GHCziTopHandler_runMainIO_closure
	.quad	Main_main_closure
.data
	.align 8
.align 1
.globl ZCMain_main_closure
.type ZCMain_main_closure, @object
ZCMain_main_closure:
	.quad	ZCMain_main_info
	.quad	0
	.quad	0
	.quad	0
.text
	.align 8
	.long	ZCMain_main_srt-(ZCMain_main_info)+0
	.long	0
	.quad	0
	.quad	12884901910
.globl ZCMain_main_info
.type ZCMain_main_info, @object
ZCMain_main_info:
.LcgC:
	leaq -16(%rbp),%rax
	cmpq %r15,%rax
	jb .LcgE
	addq $16,%r12
	cmpq 144(%r13),%r12
	ja .LcgG
	movq $stg_CAF_BLACKHOLE_info,-8(%r12)
	movq 160(%r13),%rax
	movq %rax,0(%r12)
	movq %r13,%rdi
	movq %rbx,%rsi
	leaq -8(%r12),%rdx
	subq $8,%rsp
	movl $0,%eax
	call newCAF
	addq $8,%rsp
	testq %rax,%rax
	je .LcgH
```

And finally, this is the ```GHC.TopHandler.runMainIO``` closure being called (if you haven't noticed yet, there are no ```call```s in this code at all (except for ```newCAF```), and everything is done by ```jmp``` instructions!)

The ```Main_main_closure``` above is an argument here to ```runMainIO```.

```nasm
.LcgI:
	movq $stg_bh_upd_frame_info,-16(%rbp)
	leaq -8(%r12),%rax
	movq %rax,-8(%rbp)
	movl $base_GHCziTopHandler_runMainIO_closure,%ebx
	movl $Main_main_closure,%r14d
	addq $-16,%rbp
	jmp stg_ap_p_fast
.LcgG:
	movq $16,192(%r13)
.LcgE:
	jmp *-16(%r13)
.LcgH:
	jmp *(%rbx)
	.size ZCMain_main_info, .-ZCMain_main_info
.section .note.GNU-stack,"",@progbits
.ident "GHC 7.4.1"
```

And we're done!

Running time comparison
--------------------------

(only because I couldn't help myself, usual disclaimers about 'this-is-not-a-benchmark' apply)

C++:

```bash
time (while ((n++ < 100)); do ./cpphelloworld; done)
real	0m0.250s
user	0m0.004s
sys	0m0.036s
```

Haskell:

```bash
time (while ((n++ < 100)); do ./haskellhelloworld; done)
real	0m0.366s
user	0m0.004s
sys	0m0.048s
```

Gists
-----
*Update*: I've made the complete assembly version of both 'Hello World' programs available as gists.
So you can look at [The C++ version](https://gist.github.com/agam/5148416) or [The Haskell version](https://gist.github.com/agam/5148398).
