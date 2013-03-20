---
title: Comparing basic iteration in C++ and Haskell
date: 13 Mar 2013
---

Iteration in C++ and Haskell: Part 1
============================

`For loop` iteration: C
------------------------

First, basic iteration over an array.

C++ Source :

```C
#include <iostream>
#include <vector>

int main(int argc, char**argv) { 
  std::vector<int> v { 12, 23, 34 ,45 ,56 ,67 ,78, 89 };
  for (auto i : v) { 
    std::cout << i << std::endl;
  } 
}
```

Compile/Assemble:

```shell
$ g++ -std=c++0x -S -o simpleloopcpp simpleloop.cpp
```

I've stored the result in [this
gist](https://gist.github.com/agam/5194257). As you can see, this is
_enormous_ !! And all because we introduced ```STL``` into the picture !!!

So I obviously won't include all 1742 lines here, but let's see if we can
scan some high level features and go a bit deeper into the parts of the
code we'll compare with the haskell version of this.

(Skipping some boiler plate and the initializer list creater )

```nasm
	.text
	.globl	main
	.type	main, @function
main:
.LFB1490:
	.cfi_startproc
	.cfi_personality 0x3,__gxx_personality_v0
	.cfi_lsda 0x3,.LLSDA1490
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$120, %rsp
	movl	%edi, -116(%rbp)
	movq	%rsi, -128(%rbp)
	leaq	-17(%rbp), %rax
	movq	%rax, %rdi
	.cfi_offset 3, -24
```

Here is the
[```std::initializer_list```](http://en.cppreference.com/w/cpp/utility/initializer_list) being initialized

```nasm
	call	_ZNSaIiEC1Ev
	leaq	-80(%rbp), %rax
	movl	$8, %edx
	movl	$._89, %esi
	movq	%rax, %rdi
	call	_ZNSt16initializer_listIiEC1EPKim
```

(It is declared elsewhere)

```nasm
	.size	._89, 32
._89:
	.long	12
	.long	23
	.long	34
	.long	45
	.long	56
	.long	67
	.long	78
	.long	89
```

... and then the ```vector``` initialized from it ...`

```nasm
	leaq	-17(%rbp), %rcx
	movq	-80(%rbp), %rsi
	movq	-72(%rbp), %rdx
	leaq	-112(%rbp), %rax
	movq	%rax, %rdi
.LEHB0:
	call	_ZNSt6vectorIiSaIiEEC1ESt16initializer_listIiERKS0_
```

Ignore this, it's just freeing up the ```std::allocator``` object that is
passed to the vector (the actual function signature for the constructor is
```std::vector(std::initializer_list, std::allocator const&)```)

```nasm
.LEHE0:
	leaq	-17(%rbp), %rax
	movq	%rax, %rdi
	call	_ZNSaIiED1Ev
	leaq	-112(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
```

Aha ... finally, the iteration, from beginning

```nasm
.LEHB1:
	call	_ZSt5beginISt6vectorIiSaIiEEEDTcldtfp_5beginEERT_
	movq	%rax, -64(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
```

... to end

```nasm
	call	_ZSt3endISt6vectorIiSaIiEEEDTcldtfp_3endEERT_
	movq	%rax, -48(%rbp)
	jmp	.L3
```

Beginning of the loop: we take the value of the iterator ...

```nasm
.L4:
	leaq	-64(%rbp), %rax
	movq	%rax, %rdi
	call	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv
	movl	(%rax), %eax
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %eax
	movl	%eax, %esi
```

... and print it out.
(This is the ```operator <<```, being called on the contents of ```edi```,
which is ```std::cout```)

```nasm
	movl	$_ZSt4cout, %edi
	call	_ZNSolsEi
```

And this big mangled symbol is ```std::endl```.

```nasm
	movl
$_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_, %esi
	movq	%rax, %rdi
	call	_ZNSolsEPFRSoS_E
```

BTW a useful tool to find
unmangled symbols is ```c++filt```, use it as

```shell
$ c++filt _ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_

std::basic_ostream<char, std::char_traits<char> >& std::endl<char,
std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char>
>&)

```

I googled and found an [online version of the
same](http://slush.warosu.org/c++filtjs/) but it wasn't always accurate, so
YMMV.

Moving on ... then the iterator advances along the vector ...

```nasm
	leaq	-64(%rbp), %rax
	movq	%rax, %rdi
	call	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEppEv
.L3:
	leaq	-48(%rbp), %rdx
	leaq	-64(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
```

... and if we haven't reached the end yet, jump back to the beginning of
the loop (the ```.L4``` label above)

```nasm
	call
_ZN9__gnu_cxxneIPiSt6vectorIiSaIiEEEEbRKNS_17__normal_iteratorIT_T0_EESA_
.LEHE1:
	testb	%al, %al
	jne	.L4
	leaq	-112(%rbp), %rax
	movq	%rax, %rdi
```

When done, destroy the vector (with some error handling, so
```_Unwind_Resume```)

```nasm
.LEHB2:
	call	_ZNSt6vectorIiSaIiEED1Ev
	movl	$0, %eax
	addq	$120, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
.L7:
	.cfi_restore_state
	movq	%rax, %rbx
	leaq	-17(%rbp), %rax
	movq	%rax, %rdi
	call	_ZNSaIiED1Ev
	movq	%rbx, %rax
	movq	%rax, %rdi
	call	_Unwind_Resume
.LEHE2:
.L8:
	movq	%rax, %rbx
	leaq	-112(%rbp), %rax
	movq	%rax, %rdi
	call	_ZNSt6vectorIiSaIiEED1Ev
	movq	%rbx, %rax
	movq	%rax, %rdi
.LEHB3:
	call	_Unwind_Resume
.LEHE3:
	.cfi_endproc
```

Now I've skipped _quite_ a lot of the generated assembly, and you should
look at the gist I mentioned above for the code for each of the function
calls mentioned above, e.g. the code for
the 'beginning' of the iterator:

```nasm
_ZSt5beginISt6vectorIiSaIiEEEDTcldtfp_5beginEERT_:
.LFB1564:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	_ZNSt6vectorIiSaIiEE5beginEv
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
```

(which wraps around a call to ```std::vector::begin()```)


`For loop` iteration: Haskell (Basic lists)
------------------------------

Here's a simple program that uses the standard ```Prelude``` list type.

```haskell
x = [ 12, 23, 34, 45, 56, 67, 78 ,89 ]

main = mapM_ print x
```

Full assembly is [here](https://gist.github.com/agam/5194680) ... and would
you believe it, it's one-fifth the size of the C++ assembly.

Based on our experience in the [Hello World
example](/posts/hello-world-comparison.html), the Haskell assembly won't
have a linear one-to-one mapping with the source, so let's start with the
```main``` function.

```nasm
.globl Main_main_info
.type Main_main_info, @object
Main_main_info:
.Lcuj:
	leaq -16(%rbp),%rax
	cmpq %r15,%rax
	jb .Lcul
	addq $16,%r12
	cmpq 144(%r13),%r12
	ja .Lcun
	movq $stg_CAF_BLACKHOLE_info,-8(%r12)
	movq 160(%r13),%rax
	movq %rax,0(%r12)
	movq %r13,%rdi
	movq %rbx,%rsi
	leaq -8(%r12),%rdx
```

Once again, we see the ```CAF``` allocation

```nasm
	subq $8,%rsp
	movl $0,%eax
	call newCAF
	addq $8,%rsp
	testq %rax,%rax
	je .Lcuo
.Lcup:
	movq $stg_bh_upd_frame_info,-16(%rbp)
	leaq -8(%r12),%rax
	movq %rax,-8(%rbp)
```

Somewhat boring ... it uses ```Control::MapM``` and ```
GHC::Base::IO```

```nasm
	movl $base_ControlziMonad_mapMzu_closure,%ebx
	movl $base_GHCziBase_zdfMonadIO_closure,%r14d
	movl $stc_closure,%esi
	movl $stb_closure+2,%edi
	addq $-16,%rbp
	jmp stg_ap_ppp_fast
.Lcun:
	movq $16,192(%r13)
.Lcul:
	jmp *-16(%r13)
.Lcuo:
	jmp *(%rbx)
```

... which in turn is defined as (skipping the usual paperwork of
```newCAF``` and ```stg_CAF_BLACKHOLE_info```)

```nasm
.Lcu2:
	movq $stg_bh_upd_frame_info,-16(%rbp)
	leaq -8(%r12),%rax
	movq %rax,-8(%rbp)
	movl $base_SystemziIO_print_closure,%ebx
	movl $base_GHCziShow_zdfShowInteger_closure,%r14d
	addq $-16,%rbp
	jmp stg_ap_p_fast
.Lcu0:
	movq $16,192(%r13)
.LctY:
	jmp *-16(%r13)
.Lcu1:
	jmp *(%rbx)
```

(using ```System::IO::print``` and ```GHC::Show::ShowInteger```)

So nothing much to directly glean here -- iteration isn't anything special
in haskell, it's another function call.

The assembly for the data is incredibly verbose, on the lines of 

```nasm
.data
	.align 8
.align 1
ssX_closure:
	.quad	integerzmgmp_GHCziIntegerziType_Szh_static_info
	.quad	56
.data
	.align 8
.align 1
ssZ_closure:
	.quad	ghczmprim_GHCziTypes_ZC_static_info
	.quad	ssX_closure+1
	.quad	ssW_closure+2
	.quad	0

...
...
...

.data
	.align 8
.align 1
st6_closure:
	.quad	integerzmgmp_GHCziIntegerziType_Szh_static_info
	.quad	23
.data
	.align 8
.align 1
st8_closure:
	.quad	ghczmprim_GHCziTypes_ZC_static_info
	.quad	st6_closure+1
	.quad	st5_closure+2
	.quad	0
```

`For loop` iteration: Haskell (Other list structures)
------------------------------------

Let's look at a different kind of list in haskell

```haskell
import Prelude hiding (mapM_);
import Data.Sequence;
import Data.Foldable (mapM_);

x = Data.Sequence.singleton 12 |> 23 |> 34 |> 45 |> 56 |> 67 |> 78  |> 89
main = mapM_  print  x
```

(Assembly [here](https://gist.github.com/agam/5202781))

The cells of this sequence are still constructed in what seems to me a bit
heavyweight manner:

```nasm
sEH_info:
.LcGi:
	leaq -16(%rbp),%rax
	cmpq %r15,%rax
	jb .LcGk
	addq $32,%r12
	cmpq 144(%r13),%r12
	ja .LcGm
	movq $stg_upd_frame_info,-16(%rbp)
	movq %rbx,-8(%rbp)
	movq $integerzmgmp_GHCziIntegerziType_Szh_con_info,-24(%r12)
	movq $67,-16(%r12)
	movq $sED_info,-8(%r12)
	movl $containerszm0zi4zi2zi1_DataziSequence_zbzg_closure,%ebx
	leaq -8(%r12),%r14
	leaq -23(%r12),%rsi
	addq $-16,%rbp
	jmp stg_ap_pp_fast
.LcGm:
	movq $32,192(%r13)
```

(This extract shows the closure that adds ```67``` in the list)

It's possible to construct this directly from a finite list, and the same
can be done for the ```Data.Vector``` type too :

```haskell
import Prelude hiding (mapM_);
import Data.Vector;

x = Data.Vector.fromList [ 12, 23, 34, 45, 56, 67, 78, 89 ]
main = mapM_  print  x
```

(Assembly [here](https://gist.github.com/agam/5202839))

The vector is still constructed piece by piece though:

```nasm
	movq $23,-64(%r12)
	movq $ghczmprim_GHCziTypes_ZC_con_info,-56(%r12)
	leaq -71(%r12),%rax
	movq %rax,-48(%r12)
	leaq -94(%r12),%rax
	movq %rax,-40(%r12)
	movq $integerzmgmp_GHCziIntegerziType_Szh_con_info,-32(%r12)
	movq $12,-24(%r12)
	movq $ghczmprim_GHCziTypes_ZC_con_info,-16(%r12)
	leaq -31(%r12),%rax
	movq %rax,-8(%r12)
	leaq -54(%r12),%rax
	movq %rax,0(%r12)
	movl $vectorzm0zi9zi1_DataziVector_fromList_closure,%ebx
	leaq -14(%r12),%r14
	addq $-16,%rbp
	jmp stg_ap_p_fast

```

(This extract shows the steps for picking up 23 and 12 (skipping similar
steps for the other numbers)

I was curious if there was a way to avoid constructing the list

```haskell
import Data.Vector.Unboxed as U;

x :: U.Vector Double
x = U.fromList [ 12, 23, 34, 45, 56, 67, 78, 89 ]
main = U.foldr ((>>) . print) (return ())  x
```

(Assembly [here](https://gist.github.com/agam/5203008))

```nasm
...
... (skipping numbers after 23)
...
	movq $23,-48(%r12)
	movq $ghczmprim_GHCziTypes_ZC_con_info,-40(%r12)
	leaq -55(%r12),%rax
	movq %rax,-32(%r12)
	leaq -78(%r12),%rax
	movq %rax,-24(%r12)
	movq $ghczmprim_GHCziTypes_ZC_con_info,-16(%r12)
	movq $stg_INTLIKE_closure+449,-8(%r12)
	leaq -38(%r12),%rax
	movq %rax,0(%r12)
	movl $vectorzm0zi9zi1_DataziVectorziUnboxed_fromList_closure,%ebx
	movl
$vectorzm0zi9zi1_DataziVectorziUnboxedziBase_zdfUnboxInt_closure,%r14d
	leaq -14(%r12),%rsi
	addq $-16,%rbp
	jmp stg_ap_pp_fast


```

In this case, looking at ```Core``` might help.

```haskell

Main.main :: GHC.Types.IO ()
[LclIdX]
Main.main =
  Data.Vector.Unboxed.foldr
    @ GHC.Types.Int
    @ (GHC.Types.IO ())
    Data.Vector.Unboxed.Base.$fUnboxInt
    (GHC.Base..
       @ (GHC.Types.IO ())
       @ (GHC.Types.IO () -> GHC.Types.IO ())
       @ GHC.Types.Int
       (GHC.Base.>> @ GHC.Types.IO GHC.Base.$fMonadIO @ () @ ())
       (System.IO.print @ GHC.Types.Int GHC.Show.$fShowInt))
    (GHC.Base.return
       @ GHC.Types.IO GHC.Base.$fMonadIO @ () GHC.Tuple.())
    (Data.Vector.Unboxed.fromList
       @ GHC.Types.Int
       Data.Vector.Unboxed.Base.$fUnboxInt
       (GHC.Types.:
          @ GHC.Types.Int
          (GHC.Types.I# 12)
          (GHC.Types.:
             @ GHC.Types.Int
             (GHC.Types.I# 23)
             (GHC.Types.:
                @ GHC.Types.Int
                (GHC.Types.I# 34)
                (GHC.Types.:
                   @ GHC.Types.Int
                   (GHC.Types.I# 45)
                   (GHC.Types.:
                      @ GHC.Types.Int
                      (GHC.Types.I# 56)
                      (GHC.Types.:
                         @ GHC.Types.Int
                         (GHC.Types.I# 67)
                         (GHC.Types.:
                            @ GHC.Types.Int
                            (GHC.Types.I# 78)
                            (GHC.Types.:
                               @ GHC.Types.Int
                               (GHC.Types.I# 89)
                               (GHC.Types.[] @ GHC.Types.Int))))))))))

:Main.main :: GHC.Types.IO ()
[LclIdX]
:Main.main = GHC.TopHandler.runMainIO @ () Main.main
```

But no, even in the case of a ```Data.Vector.Unboxed```, the representation
for the array data is never as compact as the C++ version.

In terms of running speed though (again, printing out tiny lists is a poor,
poor benchmark, but still) it seems close enough:

```shell
$ time (while ((n++ < 100)); do ./simpleloopcpp; done)

real	0m0.312s
user	0m0.016s
sys	0m0.044s

$ time (while ((n++ < 100)); do ./simpleloophaskell; done)

real	0m0.355s
user	0m0.024s
sys	0m0.060s
```

