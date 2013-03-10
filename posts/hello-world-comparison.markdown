---
title: Comparing "Hello World" in C++ and Haskell
date: 06 Jan 2013
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

(Omitted a bunch of library references that looked like 

```nasm
	.weakref	_ZL22__gthrw_pthread_createPmPK14pthread_attr_tPFPvS3_ES3_,pthread_create
```
)


(Coming soon!) Haskell object code:
---------------------

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

Differences in libraries linked in :-

```
agam@agam-glaptop:~/Documents/Code/Throwaway$ ldd cpphelloworld
	linux-vdso.so.1 =>  (0x00007fffcb5a7000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007ffe35064000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007ffe34ca5000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007ffe349a8000)
	/lib64/ld-linux-x86-64.so.2 (0x00007ffe35381000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007ffe34792000)

agam@agam-glaptop:~/Documents/Code/Throwaway$ ldd haskellhelloworld
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


