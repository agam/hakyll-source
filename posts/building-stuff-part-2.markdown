---
title: Learning how to build (part 2)
date: 2013-09-09
---

Learning how to build (part 2)
==================================

I wanted to get an idea of the state of open source C++ tools and idioms, so I decided to pick something small to start with.

Raw materials: getting the libraries
--------------

I already had `boost` and newly built versions of `gcc` and `libstdc++`.

First, I got another networking library I had heard about, [`cpp-netlib`](https://github.com/google/cpp-netlib). (`git clone`, then `git submodule update`)

Next, I got a logging library [`glog`](https://code.google.com/p/google-glog/), and a perf library [`gperftools`](https://code.google.com/p/gperftools/)

(Both of these required me to download a `.tar.gz` file that needed to be uncompressed)

At this point, there was already a problem of how to build stuff (!)

Glog/Gperftools came with the usual `autoconf` system, but `cpp-netlib` had to be built with `CMake`.

```shell
cmake ~/Documents/Code/AmpWorld/cpp-netlib \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER=/usr/clang_3_3/bin/clang \
  -DCMAKE_CXX_COMPILER=/usr/clang_3_3/bin/clang++
```
  
Initial problems getting this to work (in roughly chronological order) were:

- I had run `git submodule update` without `git submodule init`, so I had to clear out `CMake` temporaries, then run `init` and `update` to get them
- `Gperftools` didn't build on my machine, and required me to first install `libunwind`
- I had not specified boost include dirs, I had to run (in my case) `export BOOST_INCLUDEDIR=/opt/boost/boost_1_54_0`
- I had not installed the boost libraries that were _not_ header-only (filesystem, regex, date_time, unit_test_framework, etc)
- I couldn't figure out how to pass the right include paths through cmake, I ended up setting the environment variables instead
    (In my case this meant `export C_INCLUDE_PATH=255`.
- After these four, I still got compilation errors
  (e.g. `boost/bind/mem_fn_template.hpp:610:30: error: no matching function for call to 'get_pointer'`)
- I added `-DCMAKE_LIBRARY_PATH=/usr/gcc_4_7/lib64` to cmake, and ran `make` again
- Now I had different linker errors ... _sigh_ ... undefined references to basic C++ library symbols like `string` in boost code
- Guessed that this might have been because I had built _boost_ with _gcc_
- Tried building the relevant Boost libraries again. This time when I ran "`bootstrap.sh`" again, I got:
  `error: No best alternative for libs/coroutine/build/allocator_sources`
- WTF (!) ... found [a Superuser post that explained](http://superuser.com/questions/614472/error-while-installing-boost-1-54) a workaround,
  which was to edit `libs/coroutine/build/Jamfile.v2`
  ... and now I get _other_ weird errors: `./boost/python/detail/wrap_python.hpp:75:24: fatal error: patchlevel.h: No such file or directory`
- Needed to install stuff: `sudo apt-get install python-dev`
- Now everything _almost_ worked, but one of the files failed to compile: 
  `cpp-netlib/http/src/network/protocol/http/client.ipp:18: undefined reference to network::logging::log(network::logging::log_record const&)'`
- This error was truly bizarre because I located the source file that had this call (`logging/src/network/logging/logging.hpp`)
  and it very explicitly disabled the copy constructor that the linker was complaining of being undefined !
- Digging around in the corresponding `CMakeLists.txt` suggests this might possibly be due to logging being disabled
- (_Will this never end ?_) `/usr/bin/ld: cannot find -lcppnetlib-logging`
- Fine, just turn of the f&*ing tests
 
So finally, this is what worked:

```shell
export CC=/usr/gcc_4_7/bin/gcc4.7
export CXX=/usr/gcc_4_7/bin/g++4.7
export LD_LIBRARY_PATH=
  /usr/gcc_4_7/lib:/usr/gcc_4_7/lib64:/opt/boost/boost_1_54_0/stage/lib:$LD_LIBRARY_PATH
/usr/local/bin/cmake \
 -DCPP-NETLIB_BUILD_TESTS=OFF \
 -DCPP-NETLIB_BUILD_EXAMPLES=ON \
 -DCPP-NETLIB_DISABLE_LOGGING=OFF \
 -DCMAKE_BUILD_TYPE=Debug \
 -DCMAKE_INCLUDE_PATH=/usr/gcc_4_7/include/c++/4.7.3/ \
 -DCMAKE_LIBRARY_PATH=/usr/gcc_4_7/lib64 \
 ~/Documents/Code/AmpWorld/cpp-netlib
```

Finally, even this didn't install the libraries where I wanted them. Finally I gave up and just hacked it up:
`for f in `find /home/agam/Documents/Code/AmpWorld/cpp-netlib/ | grep 'lib.*a$'`; \
 do sudo cp $f /opt/cpp-static-libs/; done`
 
Into the furnace: a simple sample
----------

So far so good. Now it was "hello world" time (something that used atleast two of these libraries).

Or for a more basic step, replicate [cpp-netlib's hello world](http://cpp-netlib.org/0.10.1/examples/http/hello_world_client.html) first.

This was the initial version, from the web page referred above.

```C
#include <protocol/http/client.hpp>
#include <string>                  
#include <iostream>                
                                   
namespace http = network::http;
                                   
int main(int argc, char*argv[]) {
  if (argc != 2) {                 
    std::cerr << "Usage: " << argv[0] << "<url>" << std::endl;
    return 1;                      
  }                                
                                   
  try {                            
    http::client client;           
    http::client::request request(argv[1]);
    http::client::response response = client.get(request);
                                   
    // Print to standard output  
    std::cout << "Received: " << body(response);                                                                                                                                                               
  } catch (std::exception& e) {  
    std::cerr << e.what() << std::endl;
    return 1;                      
  }                                
}                                  
                                   
}  // end namespace                
```

(The version in the example on the web page referred above was different in many ways, I'll leave that as an exercise for the reader :) )

Trying to compile it thus:

`g++4.7 -std=c++11 hello-world.cpp -Icpp-netlib/http/src/ -Icpp-netlib/message/src/ -Icpp-netlib/uri/src/  -I/opt/boost/boost_1_54_0 -lcppnetlib-http-client`

(almost there, now I get `/usr/bin/ld: cannot find -lcppnetlib-http-client`)

After a round of tacking on libraries while I continued to get `undefined reference` errors, I gave up and decided it was time to get a makefile ready.

For reference (or shame, or disgust, or trivia), the one-liner I had at this point had grown to

```shell
g++4.7 hello-world.cpp \
  -L/opt/cpp-static-libs/ \
  -lcppnetlib-uri -lcppnetlib-http-client -lcppnetlib-http-message-wrappers \
  -lcppnetlib-http-client-connections -lcppnetlib-constants \
  -lcppnetlib-http-message -lcppnetlib-message -lcppnetlib-logging \
  -L/opt/boost/boost_1_54_0/stage/lib/ -lboost_system -lboost_regex \
  -lssl -lcrypt -std=c++11 \
  -Icpp-netlib/http/src/ -Icpp-netlib/message/src/ -Icpp-netlib/uri/src/ \
  -I/opt/boost/boost_1_54_0
```

Scaffolding and Fire: Creating a makefile
------------------------------------------

Time to learn CMake ! Here's [a good tutorial](http://mathnathan.com/2010/07/getting-started-with-cmake/) or actually here's [a better one](http://web.cs.swarthmore.edu/~adanner/tips/cmake.php)

This is what I came up with for `CMakeLists.txt` :

```cmake
cmake_minimum_required(VERSION 2.8)                                                                                                                                                                                                                                            
project(hello-world)
 
add_definitions(-std=c++11)
 
set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})                                                                     
 
# Search paths
set(CPP-NETLIB-SRC
  /home/agam/Documents/Code/AmpWorld/cpp-netlib)
include_directories(
  /opt/boost/boost_1_54_0
  /opt/cpp-static-libs
  ${CPP-NETLIB-SRC}/http/src
  ${CPP-NETLIB-SRC}/message/src                                                                                                        
  ${CPP-NETLIB-SRC}/uri/src                                                                                                            
  ${CPP-NETLIB-SRC}/logging/src)
link_directories(
  /opt/boost/boost_1_54_0/stage/lib                                                                                                    
  /opt/cpp-static-libs)
 
# CppNetlib libraries                                                                                                                  
set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})                                                                     
set(CPP-NETLIB-LIBS,                                                                                                                   
  cppnetlib-uri
  cppnetlib-message
  cppnetlib-message-directives
  cppnetlib-message-wrappers                                                                                                           
  cppnetlib-http-message-wrappers
  cppnetlib-http-message                                                                                                               
  cppnetlib-constants
  cppnetlib-http-client
  cppnetlib-http-client-connections                                                                                                    
  cppnetlib-logging)
 
# Boost dependencies
find_package(Boost 1.51 REQUIRED system regex)                                                                                         
set(BOOST_LIBS,                                                                                                                        
  ${Boost_SYSTEM_LIBRARY}                                                                                                              
  ${Boost_REGEX_LIBRARY})                                                                                                              
 
# Other external libraries                                                                                                             
set(EXTERNAL_LIBS,
  ssl
  crypto)                                                                                                                              
 
# Our final output
add_executable(hello-world hello-world.cpp)
target_link_libraries(hello-world                                                                                                      
  ${BOOST_LIBS}
  ${EXTERNAL_LIBS}                                                                                                                     
  ${CPP-NETLIB-LIBS})
```

However when I tried to build,

```shell
$ make
Scanning dependencies of target hello-world
[100%] Building CXX object CMakeFiles/hello-world.dir/hello-world.cpp.o
Linking CXX executable hello-world
CMakeFiles/hello-world.dir/hello-world.cpp.o: In function `(anonymous namespace)::get_filename(network::uri const&)':
hello-world.cpp:(.text+0x22): undefined reference to `network::uri::path() const'
CMakeFiles/hello-world.dir/hello-world.cpp.o: In function `main':
hello-world.cpp:(.text+0x1ee): undefined reference to `network::http::client::client()'
hello-world.cpp:(.text+0x231): undefined reference to `network::http::request::request(std::string const&)'
...
<more undefined reference errors>
```

Eventually (minutes, hours, later! I'll spare you the pain) and after becoming lightly skilled in the arts of CMake, I realized that what I needed to do (or one of the things that I _could_ do) was to explicitly declare the path of the static library, and specify their order.

So I then ended up with something like this (omitting the common parts with the listing above):

```cmake
# Specify static libraries explicitly to make Cmake happy
add_library(CPPNETLIB_URI STATIC IMPORTED)
set_property(TARGET CPPNETLIB_URI PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-uri.a)
add_library(CPPNETLIB_MESSAGE STATIC IMPORTED)
set_property(TARGET CPPNETLIB_MESSAGE PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-message.a)
add_library(CPPNETLIB_MESSAGE_DIRECTIVES STATIC IMPORTED)
set_property(TARGET CPPNETLIB_MESSAGE_DIRECTIVES PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-message-directives.a)
add_library(CPPNETLIB_MESSAGE_WRAPPERS STATIC IMPORTED)
set_property(TARGET CPPNETLIB_MESSAGE_WRAPPERS PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-message-wrappers.a)
add_library(CPPNETLIB_HTTP_MESSAGE STATIC IMPORTED)
set_property(TARGET CPPNETLIB_HTTP_MESSAGE PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-http-message.a)
add_library(CPPNETLIB_HTTP_MESSAGE_WRAPPERS STATIC IMPORTED)
set_property(TARGET CPPNETLIB_HTTP_MESSAGE_WRAPPERS PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-http-message-wrappers.a)
add_library(CPPNETLIB_CONSTANTS STATIC IMPORTED)
set_property(TARGET CPPNETLIB_CONSTANTS PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-constants.a)
add_library(CPPNETLIB_HTTP_CLIENT STATIC IMPORTED)
set_property(TARGET CPPNETLIB_HTTP_CLIENT PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-http-client.a)
add_library(CPPNETLIB_HTTP_CLIENT_CONNECTINS STATIC IMPORTED)
set_property(TARGET CPPNETLIB_HTTP_CLIENT_CONNECTINS PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-http-client-connections.a)
add_library(CPPNETLIB_LOGGING STATIC IMPORTED)
set_property(TARGET CPPNETLIB_LOGGING PROPERTY
  IMPORTED_LOCATION /opt/cpp-static-libs/libcppnetlib-logging.a)
 
set(CPPNETLIB_LIBS
  CPPNETLIB_MESSAGE_WRAPPERS
  CPPNETLIB_HTTP_MESSAGE
  CPPNETLIB_MESSAGE
  CPPNETLIB_HTTP_CLIENT
  CPPNETLIB_MESSAGE_DIRECTIVES
  CPPNETLIB_HTTP_CLIENT_CONNECTINS
  CPPNETLIB_URI
  CPPNETLIB_LOGGING
  CPPNETLIB_CONSTANTS
  CPPNETLIB_HTTP_MESSAGE_WRAPPERS
  )
```

So, not only did I have to set the `IMPORTED_LOCATION` of each library (there _has_ to be a better way to do this, doesn't there ?!) but I also had to juggle around their order relative to each other before passing `${CPPNETLIB_LIBS}` to `target_link_libraries`

Forging a networking hello-world, or 'all I want is a wget'
-------------------------------------------------------

Once this was done, I could successfully do the following:

```shell
$ mkdir build && cd build
$ cmake ..
$ make

Scanning dependencies of target hello-world
[100%] Building CXX object CMakeFiles/hello-world.dir/hello-world.cpp.o
Linking CXX executable hello-world
[100%] Built target hello-world

About %$#ing time, eh ?

Well, it still doesn't _quite_ work.

Before we see the non-working case, it's useful to see what happens on bad input:

```shell
$ ./hello-world foo
[network http/client/base.ipp:78] client_base_pimpl::client_base_pimpl(client_options const &)
[network http/client/base.ipp:80] creating owned io_service.
[network http/client/base.ipp:85] creating owned simple_connection_manager
[network http/client/simple_connection_manager.ipp:24] simple_connection_manager_pimpl::simple_connection_manager_pimpl(client_options const &)
[network http/client/simple_connection_manager.ipp:26] creating simple connection factory
[network http/client/connection/simple_connection_factory.ipp:57] simple_connection_factory::simple_connection_factory()
[network http/client/connection/connection_delegate_factory.ipp:22] connection_delegate_factory::connection_delegate_factory()
[network http/client/connection/resolver_delegate_factory.ipp:18] resolver_delegate_factory::resolver_delegate_factory()
[network http/client/connection/simple_connection_factory.ipp:33] simple_connection_factory_pimpl::simple_connection_factory_pimpl(...)
[network http/client/simple_connection_manager.ipp:61] simple_connection_manager::simple_connection_manager(client_options const &)
[network http/client/base.ipp:46] client_base::client_base()
[network http/client/facade.ipp:19] basic_client_facade::basic_client_facade()
[network http/client.ipp:18] client::client()
[network http/client/base.ipp:68] client_base::~client_base()
[network http/client/base.ipp:98] client_base_pimpl::~client_base_pimpl()
[network http/client/simple_connection_manager.ipp:73] simple_connection_manager::reset()
[network http/client/simple_connection_manager.ipp:83] simple_connection_manager::~simple_connection_manager()
[network http/client/simple_connection_manager.ipp:48] simple_connection_manager_pimpl::~simple_connection_manager_pimpl()
[network http/client/connection/simple_connection_factory.ipp:82] simple_connection_factory::~simple_connection_factory()
[network http/client/connection/resolver_delegate_factory.ipp:29] resolver_delegate_factory::~resolver_delegate_factory()
[network http/client/connection/connection_delegate_factory.ipp:47] connection_delegate_factory::~connection_delegate_factory()
[network http/client/connection_manager.ipp:16] connection_manager::~connection_manager()
Exception: Unable to parse URI string.
```

When I ran `time ./hello-world http://www.google.com`, I got

```shell
real    4m0.135s
user    0m0.020s
sys     0m0.012s
```

There were a series of calls of the following form:

```shell
[network http/client/connection/normal_delegate.ipp:38] normal_delegate::read_some(...)
[network http/client/connection/normal_delegate.ipp:39] scheduling asynchronous read some...
[network http/client/connection/normal_delegate.ipp:41] scheduled asynchronous read some...
[network http/client/connection/async_normal.ipp:237] http_async_connection_pimpl::handle_received_data(...)
[network http/client/connection/async_normal.ipp:252] processing data chunk, no error encountered so far...
[network http/client/connection/async_normal.ipp:380] parsing body...
[network http/client/connection/async_normal.ipp:414] connection still active...
[network http/client/connection/async_normal.ipp:440] no callback provided, appending to body...
[network http/client/connection/normal_delegate.ipp:38] normal_delegate::read_some(...)
[network http/client/connection/normal_delegate.ipp:39] scheduling asynchronous read some...
[network http/client/connection/normal_delegate.ipp:41] scheduled asynchronous read some...
[network http/client/connection/async_normal.ipp:237] http_async_connection_pimpl::handle_received_data(...)
[network http/client/connection/async_normal.ipp:252] processing data chunk, no error encountered so far...
[network http/client/connection/async_normal.ipp:380] parsing body...
[network http/client/connection/async_normal.ipp:382] end of the line.
[network http/client/connection/async_normal.ipp:399] no callback provided, appending to body...
```

after which it seemed to pause for a few minutes before printing out the received body.

However, this seemed to depend on the url in question. For example, trying it on a static web page that forms part of this blog, `$ time ./hello-world http://agam.github.io/posts/building-boost-clang-gcc.html` yielded

```shell
real    0m10.154s
user    0m0.024s
sys     0m0.004s
```

That's enough, for me, for now. 


