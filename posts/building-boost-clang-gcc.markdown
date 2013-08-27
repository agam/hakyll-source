---
title: In which I recall how to build stuff
date: 2013-08-26
---

In which I recall how to build stuff
====================================

It all started when I wanted to "relearn" C++. I use it everyday, but it's been so long since I first came across it 15 years ago that I've accumulated tons of bad habits and thought patterns etc, so I wanted to get a "beginner's mind" feel of it again.

The initial detour
------------------

Ok, I thought, let's read the [4th edition](http://www.amazon.com/The-Programming-Language-3rd-Edition/dp/0201889544) of Bjarne's introduction to C++, and meanwhile also get to know [Boost](http://www.boost.org/) with some familiarity.

So I downloaded the [Boost libraries](http://sourceforge.net/projects/boost/files/boost/1.54.0/boost_1_54_0.tar.bz2/download) (which took a while), and then tried to build this basic example (from the Boost FAQ)

```C
#include <iostream>
#include <algorithm>
#include <iterator>

using boost::lambda::_1;

int main() {
  typedef std::istream_iterator<int> in;
  std::for_each(
      in(std::cin), in(), std::cout << (_1 * 3) << " ");
}
```

using Clang

```shell
clang -std=c++11 -stdlib=libc++ -I/opt/boost/boost_1_54_0 example.cc -o example
```

Fork in the road
---------------

No luck

```shell
/tmp/example-oWquCX.o: In function `__cxx_global_var_init3':
example.cc:(.text+0x71): undefined reference to `std::ios_base::Init::Init()'
example.cc:(.text+0x79): undefined reference to `std::ios_base::Init::~Init()'
/tmp/example-oWquCX.o: In function `main':
example.cc:(.text+0xb3): undefined reference to `std::cin'
example.cc:(.text+0xf0): undefined reference to `std::cout'
/tmp/example-oWquCX.o: In function `std::istream_iterator<int, char, std::char_traits<char>, long>::_M_read()':
```

(and more that I'll skip over right now).

Later I realized that this was probably my fault in not linking it correctly, but I immediately, inexplicably, decided "Aha! let's build clang from source!"

This might also have been because I had gotten bored of `sudo apt-get install foo` and longed for the (decade ago) days of `emerge foo`.

Deep in the woods
-------------------

Luckily, this turned out to be [well-documented](http://solarianprogrammer.com/2013/01/17/building-clang-libcpp-ubuntu-linux/), more or less.

So I got up to the point where I got and built `clang`:

```shell
$ svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
$ cd llvm/tools
$ svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
$ mkdir build && cd build
$ ../llvm/configure --prefix=/usr/clang_3_3 \
  --enable-optimized --enable-targets=host
$ make -j 8
```

And I procedded to then build `libcxx`

```shell
$ svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
$ mkdir build_libcxx && cd build_libcxx
$ CC=clang CXX=clang++ cmake -G "Unix Makefiles" \
  -DLIBCXX_CXX_ABI=libsupc++ \
  -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.6/;\
  /usr/include/c++/4.6/x86_64-linux-gnu/" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr $HOME/Clang/libcxx
$ make
```

Mt. Doom
---------

At this point I got a compiler error. Very sad. Too bad, I thought, we need to go deeper. Time for building `gcc`/`g++` and a new version of the C++ standard library. My Ubuntu version only had `gcc` upto `4.6`, and I found [a mailing list post](http://lists.cs.uiuc.edu/pipermail/llvmbugs/2013-February/027116.html) which suggested this might be fixed in `4.7`.

I could have at this point decided to add a PPA repository and got the new libraries and binaries that way, but luckily this was [also well-documented](http://solarianprogrammer.com/2012/04/13/building-gcc-4-7-on-ubuntu-12-04/) (thank you, "Solarian Programmer", whoever you are!).

So I went ahead and downloaded [`gcc`](http://www.netgull.com/gcc/releases/gcc-4.7.3/gcc-4.7.3.tar.bz2), and what turned out to be its prerequisites, [`gmp`](ftp://ftp.gmplib.org/pub/gmp-5.1.2/gmp-5.1.2.tar.lz), [`mpfr`](http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.gz) and [`mpc`](http://www.multiprecision.org/mpc/download/mpc-1.0.tar.gz).

These I built in the usual way (`configure`, `make`, `make install`), and then had to refer to them while setting up `gcc`:

```shell
$ export LD_LIBRARY_PATH=/usr/gcc_4_7/lib:$LD_LIBRARY_PATH
$ export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/
$ export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
$ export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
$ ../gcc-4.7.2/configure --build=x86_64-linux-gnu --prefix=/usr/gcc_4_7 \
  --with-gmp=/usr/gcc_4_7 --with-mpfr=/usr/gcc_4_7 \
  --with-mpc=/usr/gcc_4_7 --enable-checking=release \
  --enable-languages=c,c++,fortran --disable-multilib \
  --program-suffix=-4.7
```

Now I could proceed where I left off earlier, with the `libcxx` build, after setting a couple of path variables:

```shell
$ export PATH=/usr/gcc_4_7/bin:$PATH
$ export LD_LIBRARY_PATH=/usr/gcc_4_7/lib:/usr/gcc_4_7/lib64:$LD_LIBRARY_PATH
```

A ray of hope
-------------

But first, I wanted to see if the new `g++` could do what I had initially tried to do with `clang`:

```shell
$ g++4.7 -std=c++11 -I/opt/boost/boost_1_54_0 example.cc -o example
$ echo 1 2 3 | ./example
3 6 9
```

Whew, now I was getting somewhere.

I went back and re-ran `cmake`, and then `libcxx` built successfully.

And then of course, I retried my original example:

```shell
$ /usr/clang_3_3/bin/clang++ -std=c++11 -I/opt/boost/boost_1_54_0 example.cc -o example
```

and that worked too ... Woohoo!!

Finally, since I always measure running time:

```shell
$ time /usr/clang_3_3/bin/clang++ -std=c++11 -I/opt/boost/boost_1_54_0 example.cc -o example

real    0m0.848s
user    0m0.780s
sys     0m0.056s

$ time g++4.7 -std=c++11 -I/opt/boost/boost_1_54_0 example.cc -o example

real    0m0.714s
user    0m0.648s
sys     0m0.044s
```

Now to do something more than this example program ...

