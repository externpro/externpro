set(xp_exdlpro REPO github.com/externpro/exdlpro TAG v25.02
  BRANCH dev
  WEB "https://github.com/externpro/exdlpro"
  DESC "build external projects with cmake"
  LICENSE "[MIT](https://github.com/externpro/exdlpro/blob/dev/LICENSE 'MIT License')"
  SHA256_Linux-arm64 d6c4a8cc47018212d9f15effe1323078344bb444612ef4642805862e2e673433
  SHA256_Linux 55e5b4b1c70882f3090026710f5a15ac4b6008cf196a041f66a1651debf3a036
  SHA256_win64 a4934d1eedddb282cc8e4ec490155df7d5ebd0deae7fc7b7c55877032a4f6676
  )
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
set(xp_flatbuffers REPO github.com/externpro/flatbuffers VER 2.0.6 XP_MODULE
  BASE google:v2.0.6 BRANCH xp2.0.6
  WEB "http://google.github.io/flatbuffers/" UPSTREAM "github.com/google/flatbuffers"
  DESC "efficient cross platform serialization library"
  LICENSE "[Apache-2.0](https://github.com/google/flatbuffers/blob/v2.0.6/LICENSE.txt 'Apache License, Version 2.0')"
  )
set(xp_fmt REPO github.com/externpro/fmt TAG v11.2.0.1
  BASE 11.2.0 BRANCH dev
  WEB "https://fmt.dev" UPSTREAM "github.com/fmtlib/fmt"
  DESC "fmtlib: a modern formatting library"
  LICENSE "[MIT](https://github.com/externpro/fmt/blob/master/LICENSE 'MIT License')"
  SHA256_Linux-arm64 e40875ae284d49555a736feef7e8541a2499ef26e8a23cc73c1cf3e34aea7a84
  SHA256_Linux 8cced6ff19d1c179c329cac9b4670e345a1c691a2f78f5478141a0211c261b13
  SHA256_win64 4ecc92aa3d83b580d62b200c20ca3d2d749d63c5091916a4462a14ab4c506b38
  )
set(xp_geos REPO github.com/externpro/geos TAG v3.13.0.3
  BASE 3.13.0 BRANCH dev
  WEB "https://libgeos.org" UPSTREAM "github.com/libgeos/geos"
  DESC "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software"
  LICENSE "[LPGL-2.1](https://trac.osgeo.org/geos/ 'LGPL version 2.1')"
  SHA256_Linux-arm64 81304bc9fd0332cb0806d8e87fb076d2a08f7b3701b22f10fbec148c6271fbbe
  SHA256_Linux 5cf8633aed023f40f11011e2b3782fe6fa74f7e7b79ec2067c61eb4760670ea1
  SHA256_win64 171b4c1488fbaf603a1f999aabfed414f4e15475f108fd786e823fa20dc416e9
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
set(xp_libiconv REPO github.com/externpro/libiconv TAG v1.18.3
  BASE v0 BRANCH dev
  WEB "https://www.gnu.org/software/libiconv/" UPSTREAM "github.com/pffang/libiconv-for-Windows/releases/tag/1.18-eed6782"
  DESC "character set conversion library"
  LICENSE "[LGPL-2.1](https://savannah.gnu.org/projects/libiconv/ 'LGPL version 2.1')"
  SHA256_Linux-arm64 c657ed54976534f99613ea71a5dc157523935dbe5dfde239ead599b095b80b3c
  SHA256_Linux c3ebfc2fdcc5976e0cabc1aa99c71f48fc5d720604c311d4f0cb28c6b9bb5f3e
  SHA256_win64 ab61310fa838d89670141a3dc313c694f9168087fad1cccc9dd2a11ce0b4a56e
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
set(xp_nasm REPO github.com/externpro/nasm TAG v2.14.02.1
  BASE v0 BRANCH dev
  WEB "https://www.nasm.us/"
  DESC "The Netwide Assembler - an 80x86 and x86-64 assembler (MSW-only)"
  LICENSE "[BSD-2-Clause](https://www.nasm.us/ 'BSD 2-Clause Simplified License')"
  SHA256_Linux-arm64 f1c934bbdef48c31b8ca5dbf53bc6798ad2788414fbcb7865bd63bacc915293f
  SHA256_Linux 3b452814ca0a2c53edffd15b5801fb1778ddfba115804c21ef03e71c31c4965b
  SHA256_win64 b9ec621141b54f4d04948d039901e92ff4712792a133780e1c6ffb4e347b6646
  )
set(xp_nodeng DIST_DIR /bpvol/src/pros/nodeng/_bld-Linux/dist/) # override with local dist directory
set(xp_nodeng # override with locally built devel package (cmake --preset=Linux; cmake --workflow --preset=LinuxRelease)
  URL_Linux-arm64 /bpvol/src/pros/nodeng/_bld-Linux/nodeng-v22.16.0.2-dr-Linux-arm64-devel.tar.xz
  SHA256_Linux-arm64 be77536fdc26105651e7920d2b993e48ad8f972591e27e20b73c9154ac9bdd7d
  )
set(xp_nodeng REPO github.com/externpro/nodeng TAG v22.16.0.2-2-ge210ba4 # override with pre-release from CI built devel package
  SHA256_Linux-arm64 c29d0219f7e6dfb048df7e945013f48d1e0899c0e300400ff96c0b1f8d7ac2fe
  SHA256_Linux 0abd6e07dcc94bb2809dd903cbd2b1a60ffe8bed3c8fda532751c6c73f833966
  SHA256_win64 88b003f7d3d60f090a7ec30f77e8c0174caedf9eec670a74018d7c5d7ba26d5f
  )
set(xp_nodeng REPO github.com/externpro/nodeng TAG v22.18.0.2
  BASE v0 BRANCH dev
  WEB "https://nodejs.org/en/blog/release/v22.18.0/"
  DESC "node executable bundled as externpro devel package to build angular (ng) projects"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v22.18.0/LICENSE 'MIT License')"
  SHA256_Linux-arm64 d0322ebd35d594b5d98b72061419c7ffc883d189be12c4f41ff45a75e6a1e41d
  SHA256_Linux fe8034ec6d35d069d4d285117440f8091964cf8d4e6d8765c76528e1a612bd06
  SHA256_win64 b84be97affa306c6ac8e82d5b016f04bb501a7f99cc8d1fb9208fdbe26edbab5
  )
set(xp_nodexp REPO github.com/externpro/nodexp TAG v14.17.6.2
  BASE v0 BRANCH dev # TRICKY: nodexp, openssl versions coordinated
  WEB "https://nodejs.org/en/blog/release/v14.17.6/"
  DESC "node/npm development platform and runtime executable bundled as externpro devel package to build addons"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v14.17.6/LICENSE 'MIT License')"
  SHA256_Linux-arm64 d1ff834c4f909652e7e7b7a9af000fbfdbbe137d833cbe638edf04290e60c3f2
  SHA256_Linux 6df479d0c832d46686401fbc4f575a8c3e93812490ef862c73310088dc9ff5e0
  SHA256_win64 43cdceaf386ccbf70d1e9cbe1ceeb76b90c0c30eac84f804dc9f2a333d028681
  )
set(xp_nvjpeg2000 REPO github.com/externpro/nvJPEG2000 TAG v0.8.1.2
  BASE v0 BRANCH dev
  WEB "https://developer.nvidia.com/nvjpeg"
  DESC "high-performance GPU-accelerated library for decoding JPEG 2000 format images"
  LICENSE "[NVIDIA](https://docs.nvidia.com/cuda/nvjpeg2000/license.html 'NVIDIA Software License Agreement')"
  SHA256_Linux-arm64 1d245c836c0eda10065dbb689a17dbd8f3370c5db8024738ae042b033a5d8071
  SHA256_Linux 966664bd491bf214cb9730e771690f61da3b53a92809ed8d03f27f042bc021b2
  SHA256_win64 f31707f118db7d4e673ac29bcf809412c6378cbd5fd5513b9534d0ce2559830f
  )
set(xp_patch REPO github.com/externpro/patch TAG v2.7.6.1
  BASE v0 BRANCH dev
  WEB "https://savannah.gnu.org/projects/patch/" UPSTREAM "git.savannah.gnu.org/cgit/patch.git"
  DESC "takes a patch file containing a difference listing produced by the diff program and applies those differences to one or more original files, producing patched versions"
  LICENSE "[GPL-3.0](https://savannah.gnu.org/projects/patch/ 'GNU General Public License v3 or later')"
  SHA256_Linux-arm64 fccd4cfbc3738f9bf191a908435026120dc050bdb5b7ad1758cf97e343557675
  SHA256_Linux f5daf4f8faae6b5599e46b72b31283af0c040e62f7df5750d2ae655cf3b7ab61
  SHA256_win64 3277e58f805f29d99699dcc2a536bb9a9034fc006661d26565afe1998c4e91af
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
set(xp_sqlite3 REPO github.com/externpro/SQLite3 TAG v3.37.2.3
  BASE 3.37.2 BRANCH dev
  WEB "https://www.sqlite.org/index.html 'SQLite website'" UPSTREAM "github.com/azadkuh/sqlite-amalgamation"
  DESC "C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine"
  LICENSE "[public domain](https://www.sqlite.org/copyright.html 'open-source, not open-contribution')"
  SHA256_Linux-arm64 561a676ca69383becfa0903c5196aa626c9b0483c35596f5e17761720e5d6163
  SHA256_Linux 213f15f0b201948435ffaaf8000c0a866074f0de0eeaa3df738341066f1fd32c
  SHA256_win64 2fe7adcf44d13c19812e275473031dfa404301571ed9b48474235a6102150173
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
set(xp_zlib REPO github.com/externpro/zlib TAG v1.2.8.3
  BASE v1.2.8 BRANCH dev
  WEB "https://zlib.net 'zlib website'" UPSTREAM "github.com/madler/zlib"
  DESC "compression library"
  LICENSE "[permissive](https://zlib.net/zlib_license.html 'zlib/libpng license, see https://en.wikipedia.org/wiki/Zlib_License')"
  SHA256_Linux-arm64 95c19ed6927df83ff0576b1384716482750d5c7b46df4864ad4ec96c35a6b2f8
  SHA256_Linux 89910287aa335e8d47fd039aa81656651f648fc4d90b8b9cb3a43fa0a1abff42
  SHA256_win64 f78f33b3813c2b7e1963ae2992bea3f4b864d52d7a4aa39dd0e6f4e03ee110b0
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
set(xp_hdf5 REPO github.com/externpro/HDF5 TAG v1.14.6.3
  BASE hdf5_1.14.6 BRANCH dev DEPS zlib
  WEB "https://www.hdfgroup.org/solutions/hdf5/" UPSTREAM "github.com/HDFGroup/hdf5"
  DESC "Utilize the HDF5 high performance data software library and file format to manage, process, and store your heterogeneous data. HDF5 is built for fast I/O processing and storage."
  LICENSE "[BSD-3-Clause](https://github.com/HDFGroup/hdf5/blob/develop/LICENSE 'BSD 3-Clause New or Revised License')"
  SHA256_Linux-arm64 4a89907858bc56ff2c67a5f8949f294d1af7643f93a5adb3b52c266bb67bffa9
  SHA256_Linux 2896fbceef31d053e3997c6549333a2c3d4b6f115cd8501433f38f21da166152
  SHA256_win64 54b9483213df7b1d28249d4c2bd3d1745aff56f15e860271288bc29415e07c17
  )
set(xp_librttopo REPO github.com/externpro/librttopo TAG v1.1.0.2
  BASE librttopo-1.1.0 BRANCH dev DEPS geos
  WEB "https://git.osgeo.org/gitea/rttopo/librttopo" UPSTREAM "github.com/CGX-GROUP/librttopo"
  DESC "RT Topology Library exposes an API to create and manage standard topologies using user-provided data stores"
  LICENSE "[GPL-2.0](https://github.com/CGX-GROUP/librttopo/blob/master/COPYING 'GNU General Public License v2.0 or later')"
  SHA256_Linux-arm64 d5c0c9f7a60953aef4f5913988f0f7809b11816ebe8ece8ead5df18322eca87e
  SHA256_Linux 2f07057f48b83d68c3560d8563b4883558366e3d65a21b6bfe8a1172176fdd7b
  SHA256_win64 3512bfe99eaf540c091c667ac20f6ecdfee1d17d0f2601206952c1d1fb9f4abe
  )
set(xp_libspatialite REPO github.com/externpro/libspatialite TAG v5.1.0.4
  BASE 5.1.0 BRANCH dev DEPS geos libiconv sqlite3 zlib
  WEB "https://www.gaia-gis.it/fossil/libspatialite/home"
  DESC "extends capabilities of SQLite, enabling ti to handle spatial data and perform spatial queries"
  LICENSE "[MPL-1.1](https://www.gaia-gis.it/fossil/libspatialite/home 'MPL tri-license: choose MPL-1.1, GPL-2.0-or-later, LGPL-2.1-or-later')"
  SHA256_Linux-arm64 ef0c3e462ded36ae5445aced34cc107808e1a821789e034ab7aaf6c780f368bb
  SHA256_Linux 44e73d86b54dff96037c63febbe9027f601e0498891c027ad8fd3473ab8fc374
  SHA256_win64 0ea69c642145d85005d74d426bae09f5dcf1c32dfd7b620543d1f8a806c456c1
  )
set(xp_libzmq REPO github.com/externpro/libzmq VER 4.3.4 XP_MODULE
  BASE zeromq:v4.3.4 BRANCH xp4.3.4 DEPS sodium
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/libzmq"
  DESC "high-performance asynchronous messaging library"
  LICENSE "[MPL-2.0](http://wiki.zeromq.org/area:licensing 'Mozilla Public License 2.0')"
  )
set(xp_node-addon-api REPO github.com/externpro/node-addon-api TAG v3.0.2.2
  BASE nodejs:3.0.2 BRANCH dev DEPS nodexp
  WEB "https://github.com/nodejs/node-addon-api" UPSTREAM "github.com/nodejs/node-addon-api"
  DESC "Module for using N-API from C++"
  LICENSE "[MIT](https://github.com/nodejs/node-addon-api/blob/3.0.2/LICENSE.md 'MIT License')"
  SHA256_Linux-arm64 0d132c932515edd6d758a90f7426804c7a5eb8379b68bd44a12a43cddfe0e254
  SHA256_Linux 685a10b6ee38c672de16ca4917007412c43a5fe69f16cdd6c4fbc90feb7aac48
  SHA256_win64 714ff5682ebef712197d172d98684d5f7a269d6e061c7bc5474ddb36806bd219
  )
set(xp_openh264 REPO github.com/externpro/openh264 VER 1.4.0 XP_MODULE
  BASE cisco:v1.4.0 BRANCH xp1.4.0 DEPS yasm
  DESC "a codec library which supports H.264 encoding and decoding"
  WEB "http://www.openh264.org/" UPSTREAM "github.com/cisco/openh264"
  LICENSE "[BSD-2-Clause](http://www.openh264.org/faq.html 'BSD 2-Clause Simplified License')"
  )
set(xp_openssl REPO github.com/externpro/openssl VER 1.1.1l XP_MODULE
  BASE openssl:OpenSSL_1_1_1l BRANCH xp_1_1_1l DEPS nasm opensslasm # TRICKY: nodexp, openssl versions coordinated
  WEB "http://www.openssl.org/" UPSTREAM "github.com/openssl/openssl"
  DESC "Cryptography and SSL/TLS Toolkit"
  LICENSE "[BSD-style](http://www.openssl.org/source/license.html 'dual OpenSSL and SSLeay License: both are BSD-style licenses')"
  )
set(xp_opensslasm REPO github.com/externpro/opensslasm VER 1.1.1l
  WEB "https://github.com/externpro-archive/node/tree/v14.17.6/deps/openssl/config/archs" # TRICKY: node, openssl versions coordinated
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
set(xp_spatialite-tools REPO github.com/externpro/spatialite-tools TAG v5.1.0.4
  BASE 5.1.0a BRANCH dev EXE_DEPS libspatialite
  WEB "https://www.gaia-gis.it/fossil/spatialite-tools/index"
  DESC "collection of open source Command Line Interface (CLI) tools supporting SpatiaLite"
  LICENSE "[GPL-3.0](https://www.gaia-gis.it/fossil/spatialite-tools/index 'GPL-3.0-or-later')"
  SHA256_Linux-arm64 4c1a589c5c6113f6eb25ea09d9b103d7610cd8c0d03d2899305a7e110d5f967a
  SHA256_Linux 9ecde69e78faf645b553322ae80e9dca4fc9d0b7b1fb5587820a8e2d1c332354
  SHA256_win64 552b068b642de56037fd1cfd5418154ea680ca6c64e22a7aa5fbd14aa3ccfbdd
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
