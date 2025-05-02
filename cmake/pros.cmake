set(xp_apr REPO github.com/externpro/apr VER 1.5.2 XP_MODULE
  BASE apache:1.5.2 BRANCH xp1.5.2
  WEB "http://apr.apache.org/" UPSTREAM "github.com/apache/apr"
  DESC "Apache Portable Runtime project"
  LICENSE "[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0.html 'Apache License, Version 2.0')"
  )
set(xp_bzip2 REPO github.com/externpro/bzip2 VER 1.0.6 XP_MODULE
  BASE v1.0.6 BRANCH xp1.0.6
  WEB "http://www.bzip.org" UPSTREAM "github.com/LuaDist/bzip2" # TODO upstream github.com/opencor/bzip2
  DESC "lossless block-sorting data compression library"
  LICENSE "[bzip2-1.0.6](https://spdx.org/licenses/bzip2-1.0.6.html 'BSD-like, modified zlib license')"
  )
set(xp_cares REPO github.com/externpro/c-ares VER 1.18.1 XP_MODULE
  BASE c-ares:cares-1_18_1 BRANCH xp-1_18_1
  WEB "http://c-ares.haxx.se/" UPSTREAM "github.com/c-ares/c-ares"
  DESC "C library for asynchronous DNS requests (including name resolves)"
  LICENSE "[MIT](http://c-ares.haxx.se/license.html 'MIT License')"
  )
set(xp_clangformat REPO github.com/llvm/llvm-project/tree/llvmorg-11.0.0/clang/tools/clang-format VER 11.0.0 XP_MODULE
  WEB "https://clang.llvm.org/docs/ClangFormat.html"
  DESC "used to format C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C# code"
  LICENSE "[Apache-2.0](https://releases.llvm.org/11.0.0/LICENSE.TXT 'Apache License v2.0 with LLVM Exceptions, see https://clang.llvm.org/features.html#license and https://llvm.org/docs/DeveloperPolicy.html#copyright-license-and-patents')"
  )
set(xp_criticalio REPO isrhub.usurf.usu.edu/internpro/CriticalIO TAG v2.0.02.8
  BASE v2.0.02 BRANCH development
  WEB "http://www.criticalio.com/"
  DESC "pre-built (MSW-only) Fibre Channel FCA2540-XMC-FF-G by Critical I/O"
  LICENSE "[commercial](https://www.criticalio.com/products/fiber-channel-board-products/fca2540-xmc-ff-g/ 'Fibre Channel Board Products FCA2540-XMC-FF-G')"
  SHA256_Linux abbcbeccfede2ab2538e85aec06f59b4d288a549f3969c5e39b666b47df06bc8
  SHA256_win64 0cf13caaaf04d55bd32ff5578eba6265579afcd287162b978a8683945eebc248
  )
set(xp_eigen REPO github.com/externpro/eigen VER 3.3.7 XP_MODULE
  BASE 3.3.7 BRANCH xp3.3.7
  WEB "http://eigen.tuxfamily.org" UPSTREAM "gitlab.com/libeigen/eigen.git"
  DESC "C++ template library for linear algebra"
  LICENSE "[MPL-2.0](http://eigen.tuxfamily.org/index.php?title=Main_Page#License 'Mozilla Public License 2.0')"
  )
set(xp_expat REPO github.com/externpro/libexpat VER 2.2.5 XP_MODULE
  BASE libexpat:R_2_2_5 BRANCH xp2.2.5
  WEB "https://libexpat.github.io" UPSTREAM "github.com/libexpat/libexpat"
  DESC "a stream-oriented XML parser library written in C"
  LICENSE "[MIT](https://github.com/libexpat/libexpat/blob/R_2_2_5/expat/COPYING 'MIT License')"
  )
set(xp_fftw REPO isrhub.usurf.usu.edu/internpro/fftw TAG v3.3.8.2
  BASE v3.3.8 BRANCH development
  WEB "http://www.fftw.org/ 'FFTW website'" UPSTREAM "github.com/FFTW/fftw3"
  DESC "Fastest Fourier Transform in the West"
  LICENSE "[commercial](http://www.fftw.org/faq/section1.html#isfftwfree 'SDL purchased commercial license from MIT 2017.09.20')"
  SHA256_Linux 9c296f908984fda88d2bb198048ccf56d32f046cff6e60b18c675b6280552deb
  SHA256_win64 e8d034171b2453d4c0981c268d7a39c6b3456584c94e91790a5d1ee32432a3c8
  )
set(xp_flatbuffers REPO github.com/externpro/flatbuffers VER 2.0.6 XP_MODULE
  BASE google:v2.0.6 BRANCH xp2.0.6
  WEB "http://google.github.io/flatbuffers/" UPSTREAM "github.com/google/flatbuffers"
  DESC "efficient cross platform serialization library"
  LICENSE "[Apache-2.0](https://github.com/google/flatbuffers/blob/v2.0.6/LICENSE.txt 'Apache License, Version 2.0')"
  )
set(xp_geos REPO github.com/externpro/geos TAG v3.13.0.1
  BASE 3.13.0 BRANCH dev
  WEB "https://libgeos.org" UPSTREAM "github.com/libgeos/geos"
  DESC "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software"
  LICENSE "[LPGL-2.1](https://trac.osgeo.org/geos/ 'LGPL version 2.1')"
  SHA256_Linux a2a077d7e4731f0e4d37a4895e71531e2229acad3160236a7cde04ffb4e3dee1
  SHA256_win64 b48fbbe84b32372a5effbaed7555bf87f308dd061d7bc0ced73c724f9deff560
  )
set(xp_geotrans REPO github.com/externpro/geotranz VER 2.4.2 XP_MODULE
  BASE v2.4.2 BRANCH xp2.4.2
  WEB "https://earth-info.nga.mil"
  DESC "geographic translator (convert coordinates)"
  LICENSE "[public domain](https://github.com/externpro/geotranz 'see GEOTRANS Terms of Use in README or download https://earth-info.nga.mil/php/download.php?file=wgs-terms')"
  )
set(xp_glew REPO github.com/externpro/glew VER 1.13.0 XP_MODULE
  BASE nigels-com:glew-1.13.0 BRANCH xp-1.13.0
  WEB "http://glew.sourceforge.net" UPSTREAM "github.com/nigels-com/glew"
  DESC "The OpenGL Extension Wrangler Library"
  LICENSE "[MIT](https://github.com/nigels-com/glew/blob/master/LICENSE.txt 'Modified BSD, Mesa 3D (renamed X11/MIT), Khronos (renamed X11/MIT)')"
  )
set(xp_gsoap REPO isrhub.usurf.usu.edu/internpro/gsoap TAG v2.8.97.3
  BASE v2.8.97 BRANCH development
  WEB "https://www.genivia.com/products.html#gsoap 'gSOAP website'" # was http://www.cs.fsu.edu/~engelen/soap.html
  DESC "toolkit for SOAP/XML Web services"
  LICENSE "[commercial](https://www.genivia.com/products.html#gsoap 'SDL purchased a commercial license 2020.Q1')" # was http://www.cs.fsu.edu/~engelen/soaplicense.html
  SHA256_Linux d4447bf40ea1952d013c23d328af9cd3d8244ff126b7856c1b1c96655a6a7b2f
  SHA256_win64 0faafb04dbb116bd66a5c958f10df83efccc8e5368f31fa55aed3edb139ce14e
  )
set(xp_jasper REPO github.com/externpro/jasper VER 1.900.1 XP_MODULE
  BASE version-1.900.1 BRANCH xp-1.900.1
  WEB "http://www.ece.uvic.ca/~frodo/jasper/" UPSTREAM "github.com/jasper-software/jasper"
  DESC "JPEG 2000 Part-1 codec implementation"
  LICENSE "[JasPer-2.0](http://www.ece.uvic.ca/~frodo/jasper/#license 'JasPer software license based on MIT License')"
  )
set(xp_jpegxp REPO github.com/externpro/jpegxp VER 24.01 XP_MODULE
  BASE jxp.240125 BRANCH jxp
  WEB "http://www.ijg.org/"
  DESC "JPEG codec with mods for Lossless, 12-bit lossy (XP)"
  LICENSE "[IJG](https://github.com/externpro/libjpeg/blob/upstream/README 'Independent JPEG Group License, see LEGAL ISSUES in README')"
  )
set(xp_jpeglossless REPO github.com/externpro/libjpeg VER 62.1
  BASE eccc424 BRANCH lossless.6b
  WEB "https://en.wikipedia.org/wiki/Lossless_JPEG#cite_note-1" UPSTREAM "github.com/LuaDist/libjpeg"
  DESC "lossless decode [submodule of: _jpegxp_]"
  LICENSE "[IJG](https://github.com/externpro/libjpeg/blob/upstream/README 'Independent JPEG Group License, see LEGAL ISSUES in README')"
  )
set(xp_jpeglossy12 REPO github.com/externpro/libjpeg VER 6b
  BASE 09a4003 BRANCH lossy12.6b
  WEB "https://libjpeg.sourceforge.net" UPSTREAM "github.com/LuaDist/libjpeg"
  DESC "lossy 12-bit encode and decode [submodule of: _jpegxp_]"
  LICENSE "[IJG](https://github.com/externpro/libjpeg/blob/upstream/README 'Independent JPEG Group License, see LEGAL ISSUES in README')"
  )
set(xp_jpeglossy8 REPO github.com/externpro/libjpeg VER 6b
  BASE 09a4003 BRANCH lossy8.6b
  WEB "https://libjpeg.sourceforge.net" UPSTREAM "github.com/LuaDist/libjpeg"
  DESC "lossy 8-bit encode and decode [submodule of: _jpegxp_]"
  LICENSE "[IJG](https://github.com/externpro/libjpeg/blob/upstream/README 'Independent JPEG Group License, see LEGAL ISSUES in README')"
  )
set(xp_jxrlib REPO github.com/externpro/jxrlib VER 15.08 XP_MODULE
  BASE v15.08 BRANCH xp15.08
  WEB "https://github.com/4creators/jxrlib" UPSTREAM "github.com/c0nk/jxrlib" # TODO upstream github.com/4creators/jxrlib
  DESC "JPEG XR Image Codec reference implementation library released by Microsoft"
  LICENSE "[BSD-2-Clause](https://github.com/4creators/jxrlib/blob/master/LICENSE 'BSD 2-Clause Simplified License')"
  )
set(xp_kakadu REPO isrhub.usurf.usu.edu/internpro/kakadu TAG v6.1.1.4
  BASE v6_1_1 BRANCH development
  WEB "http://www.kakadusoftware.com/ 'kakadu website'"
  DESC "JPEG 2000 implementation"
  LICENSE "[commercial](https://isrhub.usurf.usu.edu/internpro/kakadu/blob/sdl_6_1_1/README.md 'purchased Kakadu Software version 6.0, Commercial 250 on 18 Sep 2007')"
  SHA256_Linux cf26edb0b133ce6a85245ebf59e89bc0263ce1acc93d7f3fc555f241e7e9c9e7
  SHA256_win64 311c4b20e95ffdceb0e158236e27d075ce4db952b1001fc0fe530353d54e76da
  )
set(xp_libiconv REPO github.com/externpro/libiconv TAG v1.18.2
  BASE 1.18-eed6782 BRANCH dev
  WEB "https://www.gnu.org/software/libiconv/" UPSTREAM "github.com/pffang/libiconv-for-Windows/releases/tag/1.18-eed6782"
  DESC "character set conversion library"
  LICENSE "[LGPL-2.1](https://savannah.gnu.org/projects/libiconv/ 'LGPL version 2.1')"
  SHA256_Linux 6ed38b170b73e968f0333544f13b27118cd637a586b7bca00d4284a9f16ee793
  SHA256_win64 99e203a02633cc960929e45a97f8d6d48df89e79649d1e44ed96fb3e2fbe439e
  )
set(xp_lua REPO github.com/externpro/lua VER 5.2.3 XP_MODULE
  BASE LuaDist:5.2.3 BRANCH xp5.2.3
  WEB "http://www.lua.org/" UPSTREAM "github.com/LuaDist/lua"
  DESC "a powerful, fast, lightweight, embeddable scripting language"
  LICENSE "[MIT](http://www.lua.org/license.html 'MIT License')"
  )
set(xp_luabridge REPO github.com/vinniefalco/LuaBridge/tree/2.5 VER 2.5
  WEB "http://vinniefalco.github.io/LuaBridge/Manual.html 'LuaBridge Reference Manual'"
  DESC "a lightweight, dependency-free library for binding Lua to C++ [submodule of: _lua_]"
  LICENSE "[MIT](https://github.com/vinniefalco/LuaBridge/#official-repository 'MIT License')"
  )
set(xp_nasm REPO github.com/externpro/nasm TAG v2.14.02
  BRANCH main
  WEB "https://www.nasm.us/"
  DESC "The Netwide Assembler - an 80x86 and x86-64 assembler (MSW-only)"
  LICENSE "[BSD-2-Clause](https://www.nasm.us/ 'BSD 2-Clause Simplified License')"
  SHA256_Linux 31fb78aa856e58716b5cf36927a24824e1fc931a375b02b9c24245a5ed3e3347
  SHA256_win64 ddf6097be3ecf6e63cdcc56dbc6f063f44cf4ba04e8df73c2c6c3798c3f98428
  )
set(xp_nvjpeg2000 REPO github.com/externpro/nvJPEG2000 TAG v0.8.0.1
  BRANCH dev
  WEB "https://developer.nvidia.com/nvjpeg"
  DESC "high-performance GPU-accelerated library for decoding JPEG 2000 format images"
  LICENSE "[NVIDIA](https://docs.nvidia.com/cuda/nvjpeg2000/license.html 'NVIDIA Software License Agreement')"
  SHA256_Linux 8ee32edd1474bc7173c03085da2ee8372a73324ba13ab1941d853a07362de92a
  SHA256_win64 23258bd1043a4cb290439eb7b01fbec3af001e806cef4c8c75186f57bf1598d4
  )
set(xp_patch REPO github.com/externpro/patch TAG v2.7
  BRANCH main
  WEB "https://savannah.gnu.org/projects/patch/" UPSTREAM "git.savannah.gnu.org/cgit/patch.git"
  DESC "takes a patch file containing a difference listing produced by the diff program and applies those differences to one or more original files, producing patched versions"
  LICENSE "[GPL-3.0](https://savannah.gnu.org/projects/patch/ 'GNU General Public License v3 or later')"
  SHA256_Linux b72b6b36acd65f6dc66e988a2edbbf483377c69d9fdf1f2537f3ec474f345196
  SHA256_win64 0e7852bd14863f7e1f5ac29a29dba83d75d92963e2f4c4bb7628397a2bf96e63
  )
set(xp_rapidjson REPO github.com/externpro/rapidjson VER 1.1.0 XP_MODULE
  BASE Tencent:v1.1.0 BRANCH xp1.1.0
  WEB "http://Tencent.github.io/rapidjson/" UPSTREAM "github.com/Tencent/rapidjson"
  DESC "C++ library for parsing and generating JSON"
  LICENSE "[MIT](https://raw.githubusercontent.com/Tencent/rapidjson/master/license.txt 'MIT License')"
  )
set(xp_rapidxml REPO github.com/externpro/rapidxml VER 1.13 XP_MODULE
  BASE v1.13 BRANCH xp1.13
  WEB "http://rapidxml.sourceforge.net/"
  DESC "fast XML parser"
  LICENSE "[BSL-1.0 or MIT](http://rapidxml.sourceforge.net/license.txt 'Boost Software License or MIT License')"
  )
set(xp_shapelib REPO github.com/externpro/shapelib VER 1.2.10 XP_MODULE
  BASE v1.2.10 BRANCH xp1.2.10
  WEB "http://shapelib.maptools.org/" UPSTREAM "github.com/modgeosys/shapelib"
  DESC "reading, writing, updating ESRI Shapefiles"
  LICENSE "[MIT or LGPL](http://shapelib.maptools.org/license.html 'MIT or LGPL License')"
  )
set(xp_sodium REPO github.com/externpro/libsodium VER 21.11.18 XP_MODULE
  BASE jedisct1:aa099f5e82ae78175f9c1c48372a123cb634dd92 BRANCH xp21.11.18
  WEB "https://doc.libsodium.org/" UPSTREAM "github.com/jedisct1/libsodium"
  DESC "library for encryption, decryption, signatures, password hashing and more"
  LICENSE "[ISC](https://doc.libsodium.org/#license 'Internet Systems Consortium License, functionally equivalent to simplified BSD and MIT licenses')"
  )
set(xp_sqlite3 REPO github.com/externpro/SQLite3 TAG v3.37.2.2
  BASE 3.37.2 BRANCH dev
  WEB "https://www.sqlite.org/index.html 'SQLite website'" UPSTREAM "github.com/azadkuh/sqlite-amalgamation"
  DESC "C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine"
  LICENSE "[public domain](https://www.sqlite.org/copyright.html 'open-source, not open-contribution')"
  SHA256_Linux 4c48a644147936e5df118427308b177a9f8c276b58216b7aff4dee810b958a1f
  SHA256_win64 58d4f6b1997edaa532cdb0c9c9de287f898a69b8eeb0bc86cb4e73642d764191
  )
set(xp_wirehair REPO github.com/externpro/wirehair VER 21.07.31 XP_MODULE
  BASE catid:6d84fad40cbbbb29d4eb91204750ddffe0dcacfe BRANCH xp21.07.31
  WEB "https://github.com/catid/wirehair" UPSTREAM "github.com/catid/wirehair"
  DESC "fast and portable fountain codes in C"
  LICENSE "[BSD-3-Clause](https://github.com/catid/wirehair/blob/master/LICENSE 'BSD 3-Clause New or Revised License')"
  )
set(xp_wxwidgets REPO github.com/externpro/wxWidgets VER 3.1.0 XP_MODULE
  BASE v3.1.0_240125 BRANCH xp3.1.0
  WEB "http://wxwidgets.org/" UPSTREAM "github.com/wxWidgets/wxWidgets"
  DESC "Cross-Platform C++ GUI Library"
  LICENSE "[wxWindows](http://www.wxwidgets.org/about/newlicen.htm 'essentially LGPL with an exception')"
  )
set(xp_wxcmake REPO github.com/externpro/wxcmake
  BASE wx0 BRANCH wx31
  WEB "https://github.com/externpro/wxcmake/tree/wx31 'wxcmake repo on github, wx31 branch'"
  DESC "build wxWidgets via cmake (MSW-only) [submodule of: _wxwidgets_]"
  LICENSE "[wxWindows](http://www.wxwidgets.org/about/newlicen.htm 'same as wxWidgets license')"
  )
set(xp_yasm REPO github.com/externpro/yasm VER 1.3.0
  BASE yasm:v1.3.0 BRANCH xp1.3.0
  WEB "http://yasm.tortall.net/" UPSTREAM "github.com/yasm/yasm"
  DESC "assembler and disassembler for the Intel x86 architecture"
  LICENSE "[BSD-2-Clause](https://github.com/yasm/yasm/blob/v1.3.0/COPYING 'BSD 2-Clause Simplified License')"
  )
set(xp_zlib REPO github.com/externpro/zlib TAG v1.2.8.2
  BASE v1.2.8 BRANCH dev
  WEB "https://zlib.net 'zlib website'" UPSTREAM "github.com/madler/zlib"
  DESC "compression library"
  LICENSE "[permissive](https://zlib.net/zlib_license.html 'zlib/libpng license, see https://en.wikipedia.org/wiki/Zlib_License')"
  SHA256_Linux a624dd2ca6c999e01b80ff727e11acbcd5e2de4162221299acab1e827b3af938
  SHA256_win64 8b263c36712a53931015ea582cc09f8021f334941e3e1c18f41cf364aff73c92
  )
### depend on previous group
set(xp_boost VER 1.76.0 XP_MODULE
  DEPS bzip2 zlib
  WEB "http://www.boost.org/ 'Boost website'" UPSTREAM "github.com/boostorg/boost"
  DESC "libraries that give C++ a boost"
  LICENSE "[BSL-1.0](http://www.boost.org/users/license.html 'Boost Software License')"
  # SUBMODULES beast dll gil graph boost_install interprocess program_options regex units # TODO
  )
set(xp_ceres REPO github.com/externpro/ceres-solver VER 1.14.0 XP_MODULE
  BASE ceres-solver:1.14.0 BRANCH xp1.14.0 DEPS eigen
  WEB "http://ceres-solver.org" UPSTREAM "github.com/ceres-solver/ceres-solver"
  DESC "C++ library for modeling and solving large, complicated optimization problems"
  LICENSE "[BSD-3-Clause](http://ceres-solver.org/license.html 'BSD 3-Clause New or Revised License')"
  )
set(xp_geotiff REPO github.com/externpro/libgeotiff VER 1.2.4 XP_MODULE
  BASE v1.2.4 BRANCH xp1.2.4 DEPS wxwidgets
  WEB "http://trac.osgeo.org/geotiff/ 'GeoTIFF trac website'" # TODO upstream github.com/OSGeo/libgeotiff (fork)
  DESC "georeferencing info embedded within TIFF file"
  LICENSE "[MIT](https://github.com/OSGeo/libgeotiff/blob/master/libgeotiff/LICENSE 'MIT License or public domain')"
  )
set(xp_hdf5 REPO github.com/externpro/HDF5 TAG v1.14.6.2
  BASE hdf5_1.14.6 BRANCH dev DEPS zlib
  WEB "https://www.hdfgroup.org/solutions/hdf5/" UPSTREAM "github.com/HDFGroup/hdf5"
  DESC "Utilize the HDF5 high performance data software library and file format to manage, process, and store your heterogeneous data. HDF5 is built for fast I/O processing and storage."
  LICENSE "[BSD-3-Clause](https://github.com/HDFGroup/hdf5/blob/develop/LICENSE 'BSD 3-Clause New or Revised License')"
  SHA256_Linux 8db374f4e009a2bc1c404337ebf589af149182c635ec4262576a432b4496a053
  SHA256_win64 8e1f4ea33c57420036aa2506304dc4c8c71770def0dccb51a89142b7e03ab5b6
  )
set(xp_librttopo REPO github.com/externpro/librttopo TAG v1.1.0.1
  BASE librttopo-1.1.0 BRANCH dev DEPS geos
  WEB "https://git.osgeo.org/gitea/rttopo/librttopo" UPSTREAM "github.com/CGX-GROUP/librttopo"
  DESC "RT Topology Library exposes an API to create and manage standard topologies using user-provided data stores"
  LICENSE "[GPL-2.0](https://github.com/CGX-GROUP/librttopo/blob/master/COPYING 'GNU General Public License v2.0 or later')"
  SHA256_Linux ce59d0a74f415ea35f5aa83e7382cd81d8abb131f29d8a6c2c0346b78271a027
  SHA256_win64 59a251d2f869b99f874a0dba242ec2af3bb69e7f672659da5d7ff337b654b4fe
  )
set(xp_libspatialite REPO github.com/externpro/libspatialite TAG v5.1.0.3
  BASE 5.1.0 BRANCH dev DEPS geos libiconv sqlite3 zlib
  WEB "https://www.gaia-gis.it/fossil/libspatialite/home"
  DESC "extends capabilities of SQLite, enabling ti to handle spatial data and perform spatial queries"
  LICENSE "[MPL-1.1](https://www.gaia-gis.it/fossil/libspatialite/home 'MPL tri-license: choose MPL-1.1, GPL-2.0-or-later, LGPL-2.1-or-later')"
  SHA256_Linux 52e162824c9b271328931a923f81ae99705adbe0c6112e82ba4e77ea8024b858
  SHA256_win64 243f02109e669d86a6337ca15bd28a39ae458d459f2883920032ee4bd3ac35b0
  )
set(xp_libzmq REPO github.com/externpro/libzmq VER 4.3.4 XP_MODULE
  BASE zeromq:v4.3.4 BRANCH xp4.3.4 DEPS sodium
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/libzmq"
  DESC "high-performance asynchronous messaging library"
  LICENSE "[MPL-2.0](http://wiki.zeromq.org/area:licensing 'Mozilla Public License 2.0')"
  )
set(xp_node REPO github.com/externpro/node VER 14.17.6 XP_MODULE
  BASE nodejs:v14.17.6 BRANCH xp14.17.6 DEPS nasm # TRICKY: node, openssl versions coordinated
  WEB "http://nodejs.org" UPSTREAM "github.com/nodejs/node"
  DESC "platform to build scalable network applications"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v14.17.6/LICENSE 'MIT License')"
  )
set(xp_openh264 REPO github.com/externpro/openh264 VER 1.4.0 XP_MODULE
  BASE cisco:v1.4.0 BRANCH xp1.4.0 DEPS yasm
  DESC "a codec library which supports H.264 encoding and decoding"
  WEB "http://www.openh264.org/" UPSTREAM "github.com/cisco/openh264"
  LICENSE "[BSD-2-Clause](http://www.openh264.org/faq.html 'BSD 2-Clause Simplified License')"
  )
set(xp_openssl REPO github.com/externpro/openssl VER 1.1.1l XP_MODULE
  BASE openssl:OpenSSL_1_1_1l BRANCH xp_1_1_1l DEPS nasm opensslasm # TRICKY: node, openssl versions coordinated
  WEB "http://www.openssl.org/" UPSTREAM "github.com/openssl/openssl"
  DESC "Cryptography and SSL/TLS Toolkit"
  LICENSE "[BSD-style](http://www.openssl.org/source/license.html 'dual OpenSSL and SSLeay License: both are BSD-style licenses')"
  )
set(xp_opensslasm REPO github.com/externpro/opensslasm VER 1.1.1l
  WEB "https://github.com/externpro/node/tree/v14.17.6/deps/openssl/config/archs" # TRICKY: node, openssl versions coordinated
  DESC "openssl assembly, copied from node (deps/openssl/config/archs/) [submodule of: _openssl_]"
  LICENSE "[BSD-style](http://www.openssl.org/source/license.html 'dual OpenSSL and SSLeay License: both are BSD-style licenses')"
  )
set(xp_protobuf REPO github.com/externpro/protobuf VER 3.14.0 XP_MODULE
  BASE protocolbuffers:v3.14.0 BRANCH xp3.14.0 DEPS zlib
  WEB "https://developers.google.com/protocol-buffers/" UPSTREAM "github.com/protocolbuffers/protobuf"
  DESC "language-neutral, platform-neutral extensible mechanism for serializing structured data"
  LICENSE "[BSD-3-Clause](https://github.com/protocolbuffers/protobuf/blob/v3.14.0/LICENSE 'BSD 3-Clause New or Revised License')"
  )
set(xp_wxx REPO github.com/externpro/wxx VER 2024.01.25 XP_MODULE
  BASE wxx.03 BRANCH xpro DEPS wxwidgets
  WEB "https://github.com/externpro/wxx"
  DESC "wxWidget-based extra components"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
set(xp_wxplotctrl REPO github.com/externpro/wxplotctrl
  BASE v2006.04.28 BRANCH xp2006.04.28
  WEB "https://sourceforge.net/projects/wxcode/files/Components/wxPlotCtrl/"
  DESC "interactive xy data plotting widgets [submodule of: _wxx_]"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
set(xp_wxthings REPO github.com/externpro/wxthings
  BASE v2006.04.28 BRANCH xp2006.04.28
  WEB "https://sourceforge.net/projects/wxcode/files/Components/wxThings/"
  DESC "a variety of data containers and controls [submodule of: _wxx_]"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
set(xp_wxtlc REPO github.com/externpro/wxTLC
  BASE v1208 BRANCH xp1208
  WEB "https://sourceforge.net/projects/wxcode/files/Components/treelistctrl/"
  DESC "a multi column tree control [submodule of: _wxx_]"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
### depend on previous group
set(xp_activemqcpp REPO github.com/externpro/activemq-cpp VER 3.9.5 XP_MODULE
  BASE apache:activemq-cpp-3.9.5 BRANCH xp-3.9.5 DEPS apr openssl
  WEB "http://activemq.apache.org/cms/" UPSTREAM "github.com/apache/activemq-cpp"
  DESC "ActiveMQ C++ Messaging Service (CMS) client library"
  LICENSE "[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0.html 'Apache License, Version 2.0')"
  )
set(xp_azmq REPO github.com/externpro/azmq VER 21.12.05 XP_MODULE
  BASE zeromq:e0058a38976399006f535a9010d29e763b43fcd8 BRANCH xp21.12.05 DEPS boost libzmq
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/azmq"
  DESC "provides Boost Asio style bindings for ZeroMQ"
  LICENSE "[BSL-1.0](https://github.com/zeromq/azmq/blob/master/LICENSE-BOOST_1_0 'Boost Software License 1.0')"
  )
set(xp_cppzmq REPO github.com/externpro/cppzmq VER 4.7.1 XP_MODULE
  BASE zeromq:v4.7.1 BRANCH xp4.7.1 DEPS libzmq
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/cppzmq"
  DESC "header-only C++ binding for libzmq"
  LICENSE "[MPL-2.0](http://wiki.zeromq.org/area:licensing 'Mozilla Public License 2.0')"
  )
set(xp_dde_lib REPO isrhub.usurf.usu.edu/DDE/dde_lib TAG v0.0.0.9
  BRANCH development DEPS boost protobuf wirehair
  WEB "https://isrhub.usurf.usu.edu/DDE/dde_lib 'dde_lib project on isrhub'"
  DESC "DDE: Data Dissemination Element"
  LICENSE "[SDL](https://isrhub.usurf.usu.edu/DDE/dde_lib/commits/development 'Copyright Space Dynamics Lab: Commits')"
  SHA256_Linux 89cd585be2403a904e8241d9b1893774e275ab020275b4e1703df819ac734cb6
  SHA256_win64 dc1133d19be5f36fbc53a799a9a75f662259b67d5ec9d2f1b304fb34b4c7b350
  )
set(xp_fecpp REPO github.com/externpro/fecpp VER 0.9 XP_MODULE
  BASE v0.9 BRANCH xp0.9 DEPS boost
  WEB "http://www.randombit.net/code/fecpp/" UPSTREAM "github.com/randombit/fecpp"
  DESC "C++ forward error correction with SIMD optimizations"
  LICENSE "[BSD-2-Clause](http://www.randombit.net/code/fecpp/ 'BSD 2-Clause Simplified License')"
  )
set(xp_ffmpeg REPO github.com/ndrasmussen/FFmpeg VER 2.6.2 XP_MODULE
  BASE FFmpeg:n2.6.2 BRANCH xp2.6.2 DEPS openh264 yasm
  WEB "https://www.ffmpeg.org/" UPSTREAM "github.com/FFmpeg/FFmpeg"
  DESC "complete, cross-platform solution to record, convert and stream audio and video"
  LICENSE "[LGPL-2.1](https://www.ffmpeg.org/legal.html 'LGPL version 2.1 or later')"
  )
set(xp_ffmpegbin REPO github.com/externpro/ffmpegBin VER 2.6.2.1
  BASE v2.6.2.1 BRANCH xp2.6.2.1
  WEB "https://www.ffmpeg.org/" UPSTREAM "github.com/FFmpeg/FFmpeg"
  DESC "pre-built (MSW-only) complete, cross-platform solution to record, convert and stream audio and video"
  LICENSE "[LGPL-2.1](https://www.ffmpeg.org/legal.html 'LGPL version 2.1 or later')"
  )
set(xp_ffmpeg4 REPO github.com/externpro/FFmpeg VER 4.3.1
  BASE FFmpeg:n4.3.1 BRANCH xp4.3.1 DEPS openh264 yasm
  WEB "https://www.ffmpeg.org/" UPSTREAM "github.com/FFmpeg/FFmpeg"
  DESC "complete, cross-platform solution to record, convert and stream audio and video"
  LICENSE "[LGPL-2.1](https://www.ffmpeg.org/legal.html 'LGPL version 2.1 or later')"
  )
set(xp_libssh2 REPO github.com/externpro/libssh2 VER 1.9.0 XP_MODULE
  BASE libssh2:libssh2-1.9.0 BRANCH xp-1.9.0 DEPS openssl zlib
  WEB "http://www.libssh2.org/" UPSTREAM "github.com/libssh2/libssh2"
  DESC "client-side C library implementing SSH2 protocol"
  LICENSE "[BSD-3-Clause](http://www.libssh2.org/license.html 'BSD 3-Clause New or Revised License')"
  )
set(xp_libstrophe REPO github.com/externpro/libstrophe VER 0.9.1 XP_MODULE
  BASE strophe:0.9.1 BRANCH xp0.9.1 DEPS expat openssl
  WEB "http://strophe.im/libstrophe/" UPSTREAM "github.com/strophe/libstrophe"
  DESC "A simple, lightweight C library for writing XMPP client"
  LICENSE "[MIT or GPL-3.0](https://github.com/strophe/libstrophe/blob/0.9.1/LICENSE.txt 'dual licensed under MIT and GPLv3 licenses')"
  )
set(xp_node-addon-api REPO github.com/externpro/node-addon-api VER 3.0.2 XP_MODULE
  BASE nodejs:3.0.2 BRANCH xp3.0.2 DEPS node
  WEB "https://github.com/nodejs/node-addon-api" UPSTREAM "github.com/nodejs/node-addon-api"
  DESC "Module for using N-API from C++"
  LICENSE "[MIT](https://github.com/nodejs/node-addon-api/blob/3.0.2/LICENSE.md 'MIT License')"
  )
set(xp_palam DIST_DIR /bpvol/src/pros/palam/_bld-Linux/dist/) # override with local dist directory
set(xp_palam # override with locally built devel package (cmake --preset=Linux; cmake --workflow --preset=Linux)
  URL_Linux /bpvol/src/pros/palam/_bld-Linux/palam-v1.11.2.0-12-g6301562-Linux-devel.tar.xz
  SHA256_Linux 3cc7b6462d30557a15fca5f09c622eb39fe71a600481fbc649e83671755acbfa # cmake -E sha256sum /path/to/tar.xz
  )
set(xp_palam REPO isrhub.usurf.usu.edu/palam/palam TAG v1.11.2.1 # override with pre-release from CI built devel package
  SHA256_Linux 3c450e14932805ea3ac7548a430581cc77ab1a5b6f1bc78fff3ec2db0520aae3
  SHA256_win64 41e099602d347cec719e2ea9501760fe5f251d0154cffc0f144867ba52bff4ba
  )
set(xp_palam REPO isrhub.usurf.usu.edu/palam/palam TAG v1.11.5.0
  BRANCH development DEPS boost eigen fftw geotrans jasper jpegxp jxrlib kakadu openssl protobuf rapidjson rapidxml wxwidgets wxx
  WEB "https://isrhub.usurf.usu.edu/palam/palam 'palam project on isrhub'"
  DESC "set of libraries (organized similar to boost) for use by any Space Dynamics Lab program"
  LICENSE "[SDL](https://isrhub.usurf.usu.edu/palam/palam/commits/development 'Copyright Space Dynamics Lab: Commits')"
  SHA256_Linux 4a8d8c258a44186e045eac97d0e032bf530eb21e1df1d783906179e9c9bf93da
  SHA256_win64 e0cb2e0c1664621a7c6a753e15eb3ae348c4fcf4ee6ef481e146dda808a4a640
  SHA256_utres 502f8ed7685c1f6a215a1cba5f5765e72735849cdfb8c80de8d83ec8c38131f8
  # SUBMODULES TODO
  )
set(xp_ng_gdp REPO isrhub.usurf.usu.edu/internpro/NG_GDP TAG v24.02
  BRANCH development DEPS boost
  WEB "https://isrhub.usurf.usu.edu/internpro/NG_GDP 'SDL_GGDP and larger NG_GDP project on isrhub'"
  DESC "ground side of a guaranteed delivery protocol created by Northrup Grumman"
  LICENSE "[SDL and NG](https://isrhub.usurf.usu.edu/internpro/NG_GDP/commits/development 'Copyright Space Dynamics Lab and Northrop Grumman Private: Commits')"
  SHA256_Linux f6356221c2111223327aa70101d1d93d7fc6a11be835a3d1ec04da9353975c97
  SHA256_win64 0e0f3ba69faa7c902bf1a6dea13bde161b5622cfa6eb430909a67aa1f156148f
  )
set(xp_spatialite-tools REPO github.com/externpro/spatialite-tools TAG v5.1.0.3
  BASE 5.1.0a BRANCH dev EXE_DEPS libspatialite
  WEB "https://www.gaia-gis.it/fossil/spatialite-tools/index"
  DESC "collection of open source Command Line Interface (CLI) tools supporting SpatiaLite"
  LICENSE "[GPL-3.0](https://www.gaia-gis.it/fossil/spatialite-tools/index 'GPL-3.0-or-later')"
  SHA256_Linux 6b4d8f7090f7f0aa23ed13abc5c5bdae3bbee3605ec5243ff2b082d21c76dc1e
  SHA256_win64 86f35b3b25d428799aa2ed56bb69f754d4f8f4bc392487564ff4b0ea85198b22
  )
set(xp_wxinclude REPO github.com/externpro/wxInclude VER 1.0 XP_MODULE
  BASE v1.0 BRANCH rel EXE_DEPS boost
  WEB "http://wiki.wxwidgets.org/Embedding_PNG_Images"
  DESC "embed resources into cross-platform code"
  LICENSE "[wxWindows](http://wiki.wxwidgets.org/Embedding_PNG_Images 'assumed wxWindows license, since source can be downloaded from wxWiki')"
  )
set(xp_zmqpp REPO github.com/externpro/zmqpp VER 21.07.09 XP_MODULE
  BASE zeromq:ba4230d5d03d29ced9ca788e3bd1095477db08ae BRANCH xp21.07.09 DEPS libzmq
  WEB "https://zeromq.github.io/zmqpp/" UPSTREAM "github.com/zeromq/zmqpp"
  DESC "high-level binding for libzmq"
  LICENSE "[MPL-2.0](https://github.com/zeromq/zmqpp/blob/develop/LICENSE 'Mozilla Public License 2.0')"
  )
### depend on previous group
set(xp_curl REPO github.com/externpro/curl VER 7.80.0 XP_MODULE
  BASE curl:curl-7_80_0 BRANCH xp-7_80_0 DEPS cares libssh2
  WEB "http://curl.haxx.se/libcurl/" UPSTREAM "github.com/curl/curl"
  DESC "the multiprotocol file transfer library"
  LICENSE "[curl](http://curl.haxx.se/docs/copyright.html 'curl license inspired by MIT/X, but not identical')"
  )
set(xp_libgit2 REPO github.com/externpro/libgit2 VER 1.3.0 XP_MODULE
  BASE libgit2:v1.3.0 BRANCH xp1.3.0 DEPS libssh2
  WEB "https://libgit2.github.com/" UPSTREAM "github.com/libgit2/libgit2"
  DESC "portable, pure C implementation of the Git core methods"
  LICENSE "[GPL-2.0 WITH le](https://github.com/libgit2/libgit2/blob/master/README.md#license 'GPL2 with linking exception')"
  )
set(xp_pluginsdk REPO isrhub.usurf.usu.edu/Vantage/PluginSdk TAG v3.5.0.4
  BRANCH development EXE_DEPS palam
  WEB "https://isrhub.usurf.usu.edu/Vantage/PluginSdk 'PluginSdk project on isrhub'"
  DESC "software development kit for VANTAGE plugin development"
  LICENSE "[SDL](https://isrhub.usurf.usu.edu/Vantage/PluginSdk/commits/development 'Copyright Space Dynamics Lab: Commits')"
  SHA256_Linux da563b9390a7c65a5e1d14843cc35cda98f816db527fa20eba78d7e25527212c
  SHA256_win64 f9edef0fb2c2fe793a1202cda526775908b72dfd03739d4a366d17c373dae569
  )
set(xp_sdvideo REPO isrhub.usurf.usu.edu/internpro/Sdvideo TAG v24.02
  BRANCH development DEPS boost ffmpeg
  WEB "https://isrhub.usurf.usu.edu/internpro/Sdvideo 'Sdvideo project on isrhub'"
  DESC "MISB-compliant video encode/decode library"
  LICENSE "[SDL](https://isrhub.usurf.usu.edu/internpro/Sdvideo/commits/development 'Copyright Space Dynamics Lab: Commits')"
  SHA256_Linux 25ba1530f23c483ea1817266bad303665cdd43a265283d8f5c1cccda2068cf7f
  SHA256_win64 860006e31454e0074c9ef365210d92c199e9cdc1741fe1835ecc569344e2b0bb
  )
