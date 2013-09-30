---
title: Basic HTTP Client with Poco
date: 2013-09-29
---

Basic HTTP Client with Poco
==========================

After my previous terrible experience with `cpp-netlib`, I was very very pleasantly surprised by how well this went.

You can get the Poco C++ libraries [here](http://pocoproject.org/)

This is the short `wget` equivalent ...

```C
#include <algorithm>  // for copy
#include <iterator>
#include <string>
#include <iostream>   // for cout, istream

#include <Poco/Exception.h>
#include <Poco/Net/HTTPClientSession.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Path.h>
#include <Poco/URI.h>

using string = std::string;

int main(int argc, char*argv[]) {
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " <url>" << std::endl;
    return 1;
  }

  try {
    // Initialize session
    Poco::URI uri(argv[1]);
    Poco::Net::HTTPClientSession client_session(uri.getHost(), uri.getPort());

    // Prepare and send request
    string path(uri.getPathAndQuery());
    Poco::Net::HTTPRequest req(Poco::Net::HTTPRequest::HTTP_GET,
        path, Poco::Net::HTTPMessage::HTTP_1_1);
    client_session.sendRequest(req);

    // Get response
    Poco::Net::HTTPResponse res;
    std::istream& is = client_session.receiveResponse(res);

    // Print to standard output
    std::copy(std::istream_iterator<char>(is),
        std::istream_iterator<char>(),
        std::ostream_iterator<char>(std::cout));
  } catch (Poco::Exception& e) {
    std::cerr << "Exception: " << e.what() << std::endl;
    return 1;
  }

  std::cout << "Completed communication";
  return 0;
}
```

Thanks to my struggles getting the previous `cpp-netlib` example to build, I at least got very familiar with `cmake`. As a result, getting this example to build was a breeze:

```cmake
cmake_minimum_required(VERSION 2.8)
project(hello-world)

add_definitions(-std=c++11)

# Search paths
include_directories(
  /opt/boost/boost_1_54_0
  /usr/local/include)
link_directories(
  /opt/boost/boost_1_54_0/stage/lib
  /usr/local/lib)

# Boost dependencies
find_package(Boost 1.51 REQUIRED system regex)
set(BOOST_LIBS
  ${Boost_SYSTEM_LIBRARY}
  ${Boost_REGEX_LIBRARY}
  )

# Other external libraries
find_package(OpenSSL)
find_library(LIBCRYPTO crypto)
find_library(POCO_FOUNDATION PocoFoundation)
find_library(POCO_NET PocoNet)
set(EXTERNAL_LIBS
  ${OPENSSL_LIBRARIES}
  ${LIBCRYPTO}
  ${POCO_FOUNDATION}
  ${POCO_NET}
  )

# Our final output
add_executable(hello-world hello-world.cpp)
target_link_libraries(hello-world
  ${BOOST_LIBS}
  ${EXTERNAL_LIBS})
```

And it worked fine too:

```shell
time ./hello-world http://www.google.com
<html><head><metahttp-equiv="content-type"content="text/html;charset= ...(skipped rest)
real    0m0.424s
user    0m0.004s
sys     0m0.012s
```

I'm sure I'll be using more of POCO in the future!