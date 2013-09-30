---
title: Less Gcc, More Clang
date: 2013-09-30
---

Less GCC, More Clang
====================

I was unhappy with how I had not fully figured out my `libstdc++ <-> gcc/clang <-> boost` issues, and was feeling a bit ashamed that I had let the complexity of the system beat me.

*First, burn your boats*

The first thing I decided to do was get rid of the newly installed `gcc 4.7` and commit to getting a working version, recompiling/downloading/installing whatever it took.

The second was to recompile Boost with Clang.

```shell
export PATH=/usr/clang_3_3/bin:$PATH
./bootstrap.sh --with-toolset=clang
./b2 install --prefix=/opt/boost/boost_1_54_0
echo PATH=/opt/boost/boost_1_54_0/bin:$PATH
./b2 --build-dir=/tmp/build-boost toolset=clang stage
```

This took a while to run, but in the end, I got 

```
...failed updating 4 targets...
...skipped 6 targets...
...updated 1073 targets...
```

Wha ... 4 failed ? Scrolling up, I see for example:

```shell
clang: /home/agam/Documents/Code/Building/Clang/llvm/lib/IR/Instructions.cpp:2929: llvm::BitCastInst::BitCastInst(llvm::Value*, llvm::Type*, const llvm::Twine&, llvm::Instruction*): Assertion `castIsValid(getOpcode(), S, Ty) && "Illegal BitCast"' failed.
0  clang           0x0000000002569c72 llvm::sys::PrintStackTrace(_IO_FILE*) + 34
1  clang           0x0000000002569059
2  libpthread.so.0 0x00007f13948eecb0
3  libc.so.6       0x00007f1393919425 gsignal + 53
4  libc.so.6       0x00007f139391cb8b abort + 379
5  libc.so.6       0x00007f13939120ee
6  libc.so.6       0x00007f1393912192
7  clang           0x00000000024de388
8  clang           0x0000000002192568
9  clang           0x00000000021928ae
10 clang           0x000000000215748e
11 clang           0x00000000021584a0
12 clang           0x00000000024fa4cf llvm::FPPassManager::runOnFunction(llvm::Function&) + 607
13 clang           0x000000000224ac48
14 clang           0x000000000224e7b9
15 clang           0x00000000024f9fd0 llvm::MPPassManager::runOnModule(llvm::Module&) + 688
16 clang           0x00000000024fa1a5 llvm::PassManagerImpl::run(llvm::Module&) + 245
17 clang           0x0000000000903e8e clang::EmitBackendOutput(clang::DiagnosticsEngine&, clang::CodeGenOptions const&, clang::TargetOptions const&, clang::LangOptions const&, llvm::Module*, clang::BackendAction, llvm::raw_ostream*) + 3550
18 clang           0x00000000009013bd
19 clang           0x0000000000aa8c24 clang::ParseAST(clang::Sema&, bool, bool) + 372
20 clang           0x000000000077bafa clang::FrontendAction::Execute() + 282
21 clang           0x000000000075eca0 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 352
22 clang           0x0000000000744a8a clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 1722 23 clang           0x000000000073ddf0 cc1_main(char const**, char const**, char const*, void*) + 1232
24 clang           0x000000000072190e main + 622
25 libc.so.6       0x00007f139390476d __libc_start_main + 237
26 clang           0x000000000073d7ad
Stack dump:
0.      Program arguments: /usr/clang_3_3/bin/clang -cc1 -triple
x86_64-unknown-linux-gnu -emit-obj -disable-free -main-file-name
settings_parser.cpp -mrelocation-model pic -pic-level 2 -fmath-errno
-masm-verbose -mconstructor-aliases -munwind-tables -target-cpu x86-64
-target-linker-version 2.22 -momit-leaf-frame-pointer -coverage-file
/tmp/build-boost/boost/bin.v2/libs/log/build/clang-linux-3.4/release/log-api-
unix/threading-multi/settings_parser.o -resource-dir
/usr/clang_3_3/bin/../lib/clang/3.4 -D BOOST_ALL_NO_LIB=1 -D
BOOST_CHRONO_DYN_LINK=1 -D BOOST_DATE_TIME_DYN_LINK=1 -D
BOOST_FILESYSTEM_DYN_LINK=1 -D BOOST_LOG_DYN_LINK=1 -D
BOOST_LOG_SETUP_BUILDING_THE_LIB=1 -D BOOST_LOG_SETUP_DLL -D BOOST_LOG_USE_AVX2
-D BOOST_LOG_USE_NATIVE_SYSLOG -D BOOST_LOG_USE_SSSE3 -D
BOOST_LOG_WITHOUT_EVENT_LOG -D BOOST_SPIRIT_USE_PHOENIX_V3=1 -D
BOOST_SYSTEM_DYN_LINK=1 -D BOOST_SYSTEM_NO_DEPRECATED -D
BOOST_THREAD_BUILD_DLL=1 -D BOOST_THREAD_DONT_USE_CHRONO=1 -D BOOST_THREAD_POSIX
-D BOOST_THREAD_USE_DLL=1 -D DATE_TIME_INLINE -D NDEBUG -I . -internal-isystem
/usr/lib/gcc/x86_64-linux-gnu/4.6/../../../../include/c++/4.6 -internal-isystem
/usr/lib/gcc/x86_64-linux-gnu/4.6/../../../../include/c++/4.6/x86_64-linux-gnu
-internal-isystem
/usr/lib/gcc/x86_64-linux-gnu/4.6/../../../../include/c++/4.6/backward
-internal-isystem
/usr/lib/gcc/x86_64-linux-gnu/4.6/../../../../include/x86_64-linux-gnu/c++/4.6
-internal-isystem /usr/local/include -internal-isystem
/usr/clang_3_3/bin/../lib/clang/3.4/include -internal-externc-isystem
/usr/include/x86_64-linux-gnu -internal-externc-isystem /include
-internal-externc-isystem /usr/include -O3 -Wno-bind-to-temporary-copy
-Wno-unused-function -Wno-inline -Wall -Wno-bind-to-temporary-copy
-Wno-unused-function -fdeprecated-macro -fdebug-compilation-dir
/opt/boost/boost_1_54_0 -ferror-limit 19 -fmessage-length 0 -pthread
-mstackrealign -fobjc-runtime=gcc -fobjc-default-synthesize-properties
-fcxx-exceptions -fexceptions -fdiagnostics-show-option -vectorize-loops
-vectorize-slp -o
/tmp/build-boost/boost/bin.v2/libs/log/build/clang-linux-3.4/release/log-api-
unix/threading-multi/settings_parser.o -x c++ libs/log/src/settings_parser.cpp
1.      <eof> parser at end of file
2.      Per-module optimization passes
3.      Running pass 'CallGraph Pass Manager' on module 'libs/log/src/settings_parser.cpp'.
4.      Running pass 'Combine redundant instructions' on function '@_ZNK5boost6spirit6detail18make_binary_helperINS0_13meta_compilerINS0_2qi6domainEE12meta_grammarEE4implIRKNS_5proto7exprns_4exprINSA_6tagns_3tag10bitwise_orENSA_7argsns_5list2IRKNSC_ISF_NSH_IRNS4_4ruleIPKcNSC_INSE_8terminalENSG_4termINS0_3tag9char_codeINSN_5spaceENS0_13char_encoding8standardEEEEELl0EEENS0_11unused_typeESV_SV_EESX_EELl2EEESX_EELl2EEENS_6fusion4consINS4_10eoi_parserENS16_3nilEEERSV_EclES15_RKS1A_S1B_'
clang: error: unable to execute command: Aborted (core dumped)
clang: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 3.4 (trunk 189210)
Target: x86_64-unknown-linux-gnu
Thread model: posix
clang: note: diagnostic msg: PLEASE submit a bug report to http://llvm.org/bugs/ and include the crash backtrace, preprocessed source, and associated run script.
clang: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING FILES TO THE BUG REPORT:
Preprocessed source(s) and associated run script(s) are located at:
clang: note: diagnostic msg: /tmp/settings_parser-7f5a26.cpp
clang: note: diagnostic msg: /tmp/settings_parser-7f5a26.sh
clang: note: diagnostic msg: 

********************
```

Ignoring these few Boost failures for now ... I do want to use Clang with `-stdlib=libc++`, so I also wanted to build `libcxx` with Clang

```shell
CC=clang CXX=clang++ cmake -G "Unix Makefiles" -DLIBCXX_CXX_ABI=libsupc++ -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.6/;/usr/include/c++/4.6/x86_64-linux-gnu/" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ../libcxx/
make -j 4
sudo make install
```

Time for our test program from earlier:

```C
#include <boost/lambda/lambda.hpp>
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

However, this results in a clang error:

```shell
$ /usr/clang_3_3/bin/clang++ -std=c++11 -stdlib=libc++ -L/usr/lib -I/opt/boost/boost_1_54_0 hello-world.cpp -o hello-world -lc++abi
/usr/bin/ld: cannot find -lc++abi
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

Wohkay, so I'm assuming we need to build libc++abi

```shell
$ svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi
$ cd libcxxabi/lib
$ ./buildit
```

Now move over to the `libcxx` branch again, and 

```shell
$ CC=clang CXX=clang++ cmake -G "Unix Makefiles" -DLIBCXX_CXX_ABI=libcxxabi -DLIBCXX_LIBCXXABI_INCLUDE_PATHS="/home/agam/Documents/Code/Building/libcxxabi/include" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ../libcxx
-- The CXX compiler identification is Clang 3.4.0
-- The C compiler identification is Clang 3.4.0
-- Check for working CXX compiler: /usr/clang_3_3/bin/clang++
-- Check for working CXX compiler: /usr/clang_3_3/bin/clang++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working C compiler: /usr/clang_3_3/bin/clang
-- Check for working C compiler: /usr/clang_3_3/bin/clang -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Host triple: x86_64-pc-linux
-- Target triple: x86_64-pc-linux
CMake Error at CMakeLists.txt:119 (message):
  Failed to find cxa_demangle.h
Call Stack (most recent call first):
  CMakeLists.txt:141 (setup_abi_lib)


-- Configuring incomplete, errors occurred!
```

I looked into this and ... this seemed like a bug ? WTF. Anyway I just edited this out of `CMakeLists.txt` and tried again.

That worked! So then `make && sudo make install` as usual.

Note: I also had to copy the `libcxxabi` library built above to a global location, since I got an error trying to build `libcxx` without it

```shell
/usr/bin/ld: cannot find -lc++abi
```

After a while it occurred to me: [one does not simply copy a library to /usr/local/lib](http://memegenerator.net/instance/41718307)

```shell
$ sudo ldconfig -f /etc/ld.so.conf.d/libc.conf
$ ldconfig -p | grep c++abi
...
        libc++abi.so.1 (libc6,x86-64) => /usr/local/lib/libc++abi.so.1
```

Hmm not quite. Some [discussion I came across](http://comments.gmane.org/gmane.comp.compilers.clang.devel/30074) suggests a different format for the symlink

Yup, this was fixed by `sudo ln libc++abi.so.1.0 libc++abi.so`

Now, adding this library works:

```shell
/usr/clang_3_3/bin/clang++ -std=c++11 -stdlib=libc++ -L/usr/lib -I/opt/boost/boost_1_54_0 hello-world.cpp -o hello-world -lc++abi
```

Just to confirm, I also verified that the toy `wget` equivalent I had built with the Poco libraries works with Clang, and it does.

