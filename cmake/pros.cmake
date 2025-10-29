set(xp_exdlpro REPO github.com/externpro/exdlpro TAG v25.04
  BRANCH dev
  WEB "https://github.com/externpro/exdlpro"
  DESC "build external projects with cmake"
  LICENSE "[MIT](https://github.com/externpro/exdlpro/blob/dev/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 a5b7f8234bc4ed70ffe811ca2d28e05b0b13a6ab90aa109f934e19360f18d1c4
  SHA256_Linux-arm64 2bf1adfccbbf8dc9c8cb1f9f23a7b5091e100437ba214eeb2b8b55791e62efd5
  SHA256_Linux 127cd436523efe76e77333035ebda8f6960509e7d9188bba76821e56eb6a3299
  SHA256_win64 b7ea38e040186e9c484cb4334303859dabc7baa68c071b7ce24ed5058a101e88
  )
set(xp_apr REPO github.com/externpro/apr TAG v1.7.6.1
  BASE 1.7.6 BRANCH dev
  WEB "http://apr.apache.org/" UPSTREAM "github.com/apache/apr"
  DESC "Apache Portable Runtime project"
  LICENSE "[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0.html 'Apache License, Version 2.0')"
  SHA256_Darwin-arm64 54f95e19f086b37492b47b47cf1e805f82e6bf887eb42f67f5caf02ab8c2252c
  SHA256_Linux-arm64 b245be1af71c15625d859995c2cbbd87bb69956abcf24fa951d97e8928d2ce4d
  SHA256_Linux b42262a1e8f6e84990482b8c8b1a4107f8e798fed19aa541cec57e5544c6f26f
  SHA256_win64 12004ff076d3fc1442f9211fbf4eb9c29d8248bf178b0c729abbd17a88b3ec80
  )
set(xp_argon2 REPO github.com/externpro/argon2 TAG v20210625.1
  BASE 20210625 BRANCH dev
  WEB "https://www.password-hashing.net" UPSTREAM "github.com/P-H-C/phc-winner-argon2"
  DESC "The reference C implementation of the Argon2, the password-hashing function that won the Password Hashing Competition (PHC)"
  LICENSE "[CC0-1.0 or Apache-2.0](https://github.com/P-H-C/phc-winner-argon2/blob/master/LICENSE 'dual licensed under Creative Commons Zero v1.0 Universal and Apache License, Version 2.0')"
  SHA256_Darwin-arm64 1682cf01eb81cd6131dd47f9d4e7799b594882bda5f1f034cd52939134c2d03a
  SHA256_Linux-arm64 55587523e38ac32ad52500f0c374505f16caec80c92c231ab1e8b7ed432ee2d3
  SHA256_Linux ea7a773da6aca9ec9766e6a1ae680b9375c068375bb2fdaee959745a4190a69c
  SHA256_win64 fa649f8c8975985f9714f11c500aef67468fc66801611aa067bbb489e9814da2
  )
set(xp_bzip2 REPO github.com/externpro/bzip2 TAG v1.0.8.2
  BASE bzip2-1.0.8 BRANCH dev
  WEB "https://sourceware.org/bzip2/" UPSTREAM "github.com/opencor/bzip2"
  DESC "lossless block-sorting data compression library"
  LICENSE "[bzip2-1.0.6](https://spdx.org/licenses/bzip2-1.0.6.html 'BSD-like, modified zlib license')"
  SHA256_Darwin-arm64 0f374987ed8a6679715d7f2f45c4beeece7cfa8241fcd1be22f5f2c2d444b67d
  SHA256_Linux-arm64 455f31331c9de2e23de817f217c1dade0cb6b24bd025ff0db8f284a2cef701de
  SHA256_Linux 2a0e485c83d7c6c69dcfbe15409af4d896a4dc898b854f1e8812ea6d4d5e1d8c
  SHA256_win64 cc9a1b482e6833a47020b2a9a18c38edb9a23f236ec4894598e761ed047d5b7e
  )
set(xp_cares REPO github.com/externpro/c-ares VER 1.18.1 XP_MODULE
  BASE c-ares:cares-1_18_1 BRANCH xp-1_18_1
  WEB "http://c-ares.haxx.se/" UPSTREAM "github.com/c-ares/c-ares"
  DESC "C library for asynchronous DNS requests (including name resolves)"
  LICENSE "[MIT](http://c-ares.haxx.se/license.html 'MIT License')"
  )
set(xp_clang-format REPO github.com/externpro/clang-format TAG v19.1.5.1
  BASE v0 BRANCH dev
  WEB "https://clang.llvm.org/docs/ClangFormat.html" UPSTREAM "github.com/llvm/llvm-project"
  DESC "used to format C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C# code (clang/tools/clang-format in upstream repo)"
  LICENSE "[Apache-2.0](https://releases.llvm.org/11.0.0/LICENSE.TXT 'Apache License v2.0 with LLVM Exceptions, see https://clang.llvm.org/features.html#license and https://llvm.org/docs/DeveloperPolicy.html#copyright-license-and-patents')"
  SHA256_Darwin-arm64 5d3559dce45e20b32a64e19e63ef9aee6b6385c8869ab00d8d49e60e85021e72
  SHA256_Linux-arm64 10bc83ac98e7e7090c57a1dc66722ef5b77d6902b4b8b5d94b3e08dec79eed73
  SHA256_Linux 5ee07eddc025462bcfaa44e32547b43951ee03099b13b789866d0047a47e5524
  SHA256_win64 c75c1d540ff8ed273b140c2e2c6f13bc978a65539d57c6e35ec001e149d85b89
  )
set(xp_eigen REPO github.com/externpro/eigen TAG v3.4.0.1
  BASE 3.4.0 BRANCH dev
  WEB "http://eigen.tuxfamily.org" UPSTREAM "gitlab.com/libeigen/eigen.git"
  DESC "C++ template library for linear algebra"
  LICENSE "[MPL-2.0](http://eigen.tuxfamily.org/index.php?title=Main_Page#License 'Mozilla Public License 2.0')"
  SHA256_Darwin-arm64 28d72a94b2c5c4ef2786c2847c1d69d7e9d3c52d080b15339a2d93edcffa36c7
  SHA256_Linux-arm64 235f7a351de94000ad7e2b46fe8f1f503c86ffb573d40a5d27377964d374299f
  SHA256_Linux 78a03eb8d1b3b6161b3d2de440172e456a13723cc9ae4730df5933589167f46e
  SHA256_win64 9bec874c71af9d899e0ab68f470d1ed2208004178a400ea04babe803358995cf
  )
set(xp_expat REPO github.com/externpro/libexpat VER 2.2.5 XP_MODULE
  BASE libexpat:R_2_2_5 BRANCH xp2.2.5
  WEB "https://libexpat.github.io" UPSTREAM "github.com/libexpat/libexpat"
  DESC "a stream-oriented XML parser library written in C"
  LICENSE "[MIT](https://github.com/libexpat/libexpat/blob/R_2_2_5/expat/COPYING 'MIT License')"
  )
set(xp_flatbuffers REPO github.com/externpro/flatbuffers TAG v25.2.10.1
  BASE v25.2.10 BRANCH dev
  WEB "http://google.github.io/flatbuffers/" UPSTREAM "github.com/google/flatbuffers"
  DESC "efficient cross platform serialization library"
  LICENSE "[Apache-2.0](https://github.com/google/flatbuffers/blob/v25.2.10/LICENSE 'Apache License, Version 2.0')"
  SHA256_Darwin-arm64 16bacbf0607ff852a8c6d5d13464d73eb377db2e792cc68b63806b580f5120ec
  SHA256_Linux-arm64 8f77592551594a04ee8d2f85cf9164ad1c39ffed3bf3f9dba82cadaec82271b2
  SHA256_Linux 952061515c851ce9c89500a7311a72d7d7494627dc52f588a66df76d386adf5e
  SHA256_win64 650f5866d26ad36f06166b18f371dd46c76ee2c68dd7f094fcefb77d347d60a8
  )
set(xp_fmt REPO github.com/externpro/fmt TAG v11.2.0.3
  BASE 11.2.0 BRANCH dev
  WEB "https://fmt.dev" UPSTREAM "github.com/fmtlib/fmt"
  DESC "fmtlib: a modern formatting library"
  LICENSE "[MIT](https://github.com/externpro/fmt/blob/master/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 621c03453353b883c102c946c67602b01ff1e320b75b646643b9a64d4c8dc0d7
  SHA256_Linux-arm64 95576eb85a11717e6b120600817487db351db136b403b269b334ec24aec5decd
  SHA256_Linux f4f65488036cfb48763ac89cc3c92b3182d043e74ad962cb094005bd202ff123
  SHA256_win64 524a02569353895cf30cbb2c8cd1a81585afb04a6a5cf695234cbb6498df777d
  )
set(xp_geos REPO github.com/externpro/geos TAG v3.13.0.4
  BASE 3.13.0 BRANCH dev
  WEB "https://libgeos.org" UPSTREAM "github.com/libgeos/geos"
  DESC "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software"
  LICENSE "[LPGL-2.1](https://trac.osgeo.org/geos/ 'LGPL version 2.1')"
  SHA256_Darwin-arm64 ada51bf5945990e63a7e3856545410e3af8c1f54a45ae75239ba20ec61166809
  SHA256_Linux-arm64 08026046256fc7ba251932a1cf8ecb636a59ad92ba59bcbdbbde9f44a16c945f
  SHA256_Linux 2853045a06fd25535bbd157cea19bf0d9073882c58f179b0eb790544d3ba9a34
  SHA256_win64 bb776f18b782d4287db2b81dbd85831776836a06c4da344aaac7dbbffedea740
  )
set(xp_geotranz REPO github.com/externpro/geotranz TAG v2.4.2.1
  BASE v2.4.2 BRANCH dev
  WEB "https://earth-info.nga.mil"
  DESC "geographic translator (convert coordinates)"
  LICENSE "[public domain](https://github.com/externpro/geotranz 'see GEOTRANS Terms of Use in README or download https://earth-info.nga.mil/php/download.php?file=wgs-terms')"
  SHA256_Darwin-arm64 35bc276cafb52bacf1b232c36a990e709a1a6bebad066c4a8e657b4026149af5
  SHA256_Linux-arm64 52afe07b245405d7c7ec093c68377cf2eec636268ca40b7b536536b212aec688
  SHA256_Linux 22aa67e65c8c9034ae060fd34a09238328bfc9a55d1bfd4b6d4d6b0bef03fb2e
  SHA256_win64 687cee720040645ba293d51c2c8d1353fd256fe9e7058198324493f9dbc7db2b
  )
set(xp_glew REPO github.com/externpro/glew VER 1.13.0 XP_MODULE
  BASE nigels-com:glew-1.13.0 BRANCH xp-1.13.0
  WEB "http://glew.sourceforge.net" UPSTREAM "github.com/nigels-com/glew"
  DESC "The OpenGL Extension Wrangler Library"
  LICENSE "[MIT](https://github.com/nigels-com/glew/blob/master/LICENSE.txt 'Modified BSD, Mesa 3D (renamed X11/MIT), Khronos (renamed X11/MIT)')"
  )
set(xp_googletest REPO github.com/externpro/googletest TAG v1.16.0.1
  BASE v1.16.0 BRANCH dev
  WEB "https://google.github.io/googletest/" UPSTREAM "github.com/google/googletest"
  DESC "GoogleTest - Google Testing and Mocking Framework"
  LICENSE "[BSD-3-Clause](https://github.com/google/googletest/blob/master/LICENSE 'BSD 3-Clause New or Revised License')"
  SHA256_Darwin-arm64 43e5f07d68aef4d6f0f981d054e77bbe099214c22cc14fd3543c14a27808c01a
  SHA256_Linux-arm64 23787bd9536a33003ad84cb756899ed4ac6e6ef287c66f50b7bc57433f929ed6
  SHA256_Linux 9ca3f35c60306fbcd14038772b0cce5fd3e81c371beebf5472ae80a33887a431
  SHA256_win64 479ab2c6dd7bccabe2c41cad27399d441d32667c563a1428f8fd154072bb8858
  )
set(xp_jasper REPO github.com/externpro/jasper TAG v1.900.1.1
  BASE version-1.900.1 BRANCH dev
  WEB "https://jasper-software.github.io/jasper/" UPSTREAM "github.com/jasper-software/jasper"
  DESC "JasPer is a software toolkit for the handling of image data. It was initially developed as a reference implementation of the JPEG 2000 Part-1 codec."
  LICENSE "[JasPer-2.0](https://github.com/jasper-software/jasper/blob/master/LICENSE.txt 'JasPer software license based on MIT License')"
  SHA256_Darwin-arm64 59acfce4e6bd7b2de6facae10fd086f137e567e13dc925bcfe289d7355525ee3
  SHA256_Linux-arm64 c3de594a78c3c97178e582ee353d1cadb4fb9d337a42eae86fc75861d6881521
  SHA256_Linux 0f6ac4aade72a0d0cbecbd5cdd4113486051edfc99516927fd0f33e632a68378
  SHA256_win64 a3c516004b010fd280c342e1c3f42bed9b1752b6b47bb3882d40d62315a2c56b
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
set(xp_jxrlib REPO github.com/externpro/jxrlib TAG v2019.10.9.1
  BASE v2019.10.9 BRANCH dev
  WEB "https://github.com/4creators/jxrlib" UPSTREAM "github.com/4creators/jxrlib"
  DESC "JPEG XR Image Codec reference implementation library released by Microsoft"
  LICENSE "[BSD-2-Clause](https://github.com/4creators/jxrlib/blob/master/LICENSE 'BSD 2-Clause Simplified License')"
  SHA256_Darwin-arm64 42a7f5889774f4ba141b59ef3bbfa7ca27928a19238163273a3c2d53983a7f59
  SHA256_Linux-arm64 bbd1e172e91e77598a47f48d5b950b7c7417180268e92590f0674be50cbb9f93
  SHA256_Linux 2e79d179fb0ae0ee5347f346bc017f7f94240f79af241aeb90dd520451d57d49
  SHA256_win64 505f1984cd8950cf1d4a52a95b76340c334632318cb59e83ba05fac7d6050df0
  )
set(xp_libiconv REPO github.com/externpro/libiconv TAG v1.18.6
  BASE v0 BRANCH dev
  WEB "https://www.gnu.org/software/libiconv/" UPSTREAM "github.com/pffang/libiconv-for-Windows/releases/tag/1.18-eed6782"
  DESC "character set conversion library"
  LICENSE "[LGPL-2.1](https://savannah.gnu.org/projects/libiconv/ 'LGPL version 2.1')"
  SHA256_Darwin-arm64 8208515a4331ae73483bcbb0a7b718e2a8a4f85caddf857c11a047a3153af392
  SHA256_Linux-arm64 a49a6558cca5bc66050c8034d7120145344a5fcfa98f8859762ca7e32c53622d
  SHA256_Linux 7c24a6ae1fad58ed8560aa3e39f5475483bad27719e51b77ec140a41e0b3d558
  SHA256_win64 2e196d43265bb2af3f419358b686f3a220ca76f08113e2d162dd3b334934985c
  )
set(xp_libsodium REPO github.com/externpro/libsodium TAG v1.0.18.221
  BASE jedisct1:aa099f5e82ae78175f9c1c48372a123cb634dd92 BRANCH dev
  WEB "https://doc.libsodium.org/" UPSTREAM "github.com/jedisct1/libsodium"
  DESC "library for encryption, decryption, signatures, password hashing and more"
  LICENSE "[ISC](https://doc.libsodium.org/#license 'Internet Systems Consortium License, functionally equivalent to simplified BSD and MIT licenses')"
  SHA256_Darwin-arm64 8b269b29ea6f389ccf8d457005a016019f6fa32f8fa70161dfb33a6403e06421
  SHA256_Linux-arm64 b44dd44cbe5aa3b0d4dd777a83c9ed9c850096898dc9d134cd3a87f47137a110
  SHA256_Linux ef476149bdaa409774cd6dda73e9fe8cdf5e7d0475a91a8a349ee8baa79dccd7
  SHA256_win64 ba76566a2add1a1a5f43b87194d5ecc5b748616a29c3c995950e4e98ded46182
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
set(xp_nasm REPO github.com/externpro/nasm TAG v2.14.02.2
  BASE v0 BRANCH dev
  WEB "https://www.nasm.us/"
  DESC "The Netwide Assembler - an 80x86 and x86-64 assembler (MSW-only)"
  LICENSE "[BSD-2-Clause](https://www.nasm.us/ 'BSD 2-Clause Simplified License')"
  SHA256_Darwin-arm64 381bcd1a5e7d98a8db694b6101349544a58510068a654e67d7244b38d70f222f
  SHA256_Linux-arm64 6d2b1b6ebc8af910d7930fc324e4bb2d50fefb27283ac0a5694cdae47e9a82eb
  SHA256_Linux 9a7a6e110d7a2187af79b7045f16320e022e7e9fed7113b7cde5f5d98e3aace8
  SHA256_win64 d0e1791fb20264cc3d0a3e7f995c220afb326bc9d6cf983be23d63fd39ca48a2
  )
set(xp_nlohmann_json REPO github.com/externpro/nlohmann_json TAG v3.12.0.1
  BASE v3.12.0 BRANCH dev
  WEB "https://json.nlohmann.me" UPSTREAM "github.com/nlohmann/json"
  DESC "JSON for Modern C++"
  LICENSE "[MIT](https://github.com/nlohmann/json/blob/develop/LICENSE.MIT 'MIT License')"
  SHA256_Darwin-arm64 b5631660b006ccc13f282be4c30f41ddf18ed0f2ab6c56b9c7176377dd51a472
  SHA256_Linux-arm64 be2efc38fd6585c4b50ec8878fe411bc6c443c13d2e60f5192236abf8931703d
  SHA256_Linux 4960bad21fc64c0e05af8879421f1b60c6a5af965e4690641eb9b793474678eb
  SHA256_win64 cbcc1cdb845dda2e5f26d73d77cd66206b28cba03bc22b6dbb43b567d759b528
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
set(xp_nodeng REPO github.com/externpro/nodeng TAG v22.19.0.1
  BASE v0 BRANCH dev
  WEB "https://nodejs.org/en/blog/release/v22.19.0/"
  DESC "node executable bundled as externpro devel package to build angular (ng) projects"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v22.19.0/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 30e8956f5a7ef839af9b3b9bf491e16744987a9fdb6b26d832a97c657fd3d51f
  SHA256_Linux-arm64 23d7ce5a243117f4ee2c4b67a1fd90e4e012f7ac732202126c18804b7808b8df
  SHA256_Linux 60210d3228bee5c4f1e75edd6b42fa2a01e1b2d19a8bf6a968ff499984ffcd3f
  SHA256_win64 a3c990d9de9ebb29f4967b10dd9ae66472f8bf37e45c899d80914d5d25d2c890
  )
set(xp_nodexp REPO github.com/externpro/nodexp TAG v22.19.0.1
  BASE v0 BRANCH dev # TRICKY: nodexp, openssl versions coordinated
  WEB "https://nodejs.org/en/blog/release/v22.19.0/"
  DESC "node/npm development platform and runtime executable bundled as externpro devel package to build addons"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v22.19.0/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 8041f0516a5f40ad2845e188ceac2aa34f1c08e7229d8e9d0322ba77c734c52b
  SHA256_Linux-arm64 129d55ca8046fab214b8e41278e43fd2e450a497548081424820fcb2828026df
  SHA256_Linux c1c9bf87b6a6eee4010dfcbd8fbca8d8142ca707a53cd6e4617f0a559334014c
  SHA256_win64 220446e3ba9e5aa83bc7e970062922f066e0803bbc78de0e2568dddfaec8dfc7
  )
set(xp_nvjpeg2000 REPO github.com/externpro/nvJPEG2000 TAG v0.8.1.3
  BASE v0 BRANCH dev
  WEB "https://developer.nvidia.com/nvjpeg"
  DESC "high-performance GPU-accelerated library for decoding JPEG 2000 format images (not available on macOS)"
  LICENSE "[NVIDIA](https://docs.nvidia.com/cuda/nvjpeg2000/license.html 'NVIDIA Software License Agreement')"
  SHA256_Darwin-arm64 f509fa5b26e97fa4c3a72d8a871a811182f958086dd93dff741c1de5accb27da
  SHA256_Linux-arm64 77b374aab05acc02fbaffa0c50476b30e9c2a0446922498786216d9ab58964df
  SHA256_Linux 3af2f9f73f79941b8a7ed12d1b158f1c2222b96b4857eb41bf0bda79e816d016
  SHA256_win64 86a810f9feb0495130c7b093a4e004b5764f57821f8e2f7739a973d5bb445e67
  )
set(xp_patch REPO github.com/externpro/patch TAG v2.7.6.4
  BASE v0 BRANCH dev
  WEB "https://savannah.gnu.org/projects/patch/" UPSTREAM "git.savannah.gnu.org/cgit/patch.git"
  DESC "takes a patch file containing a difference listing produced by the diff program and applies those differences to one or more original files, producing patched versions"
  LICENSE "[GPL-3.0](https://savannah.gnu.org/projects/patch/ 'GNU General Public License v3 or later')"
  SHA256_Darwin-arm64 ca3fb3bdfe73367de3713abfe2b8a61ebcb718e7d90a842676939cfb51d35773
  SHA256_Linux-arm64 896510084c48565a2069fff5e0362b8d469a8822aa551990597f333591776159
  SHA256_Linux 28a0698ec9881d6a8414409d36b59f000f6113559a76fe2e68dc88142c75a92b
  SHA256_win64 aab7af2d24e547946aa0d4468ca2bee2487970175ce10c595954fa782e3f7c32
  )
set(xp_rapidjson REPO github.com/externpro/rapidjson TAG v1.1.0-763.1
  BASE v1.1.0-763 BRANCH dev
  WEB "http://Tencent.github.io/rapidjson/" UPSTREAM "github.com/Tencent/rapidjson"
  DESC "A fast JSON parser/generator for C++ with both SAX/DOM style API"
  LICENSE "[MIT](https://raw.githubusercontent.com/Tencent/rapidjson/master/license.txt 'MIT License')"
  SHA256_Darwin-arm64 360657595f6aaef3856578dbefcc3445673ff8827c5019d0b38b9eefc49ab4ce
  SHA256_Linux-arm64 37b38fc1ea0a2a098e4d2fd1c02617f605a230656eeda1c6d424bf8e13238950
  SHA256_Linux 6941459e00591d97b52cf3e50aae16c09c4de288f17ae1bf50ab8c4f0398bcf0
  SHA256_win64 b4029d033a9f41b54009e38824ec177d849138a2add3b02462480a2eff0dfbea
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
set(xp_sqlite3 REPO github.com/externpro/SQLite3 TAG v3.38.2.1
  BASE 3.38.2 BRANCH dev
  WEB "https://www.sqlite.org/index.html 'SQLite website'" UPSTREAM "github.com/azadkuh/sqlite-amalgamation"
  DESC "C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine"
  LICENSE "[public domain](https://www.sqlite.org/copyright.html 'open-source, not open-contribution')"
  SHA256_Darwin-arm64 2845d6b59ddcb11e4c09e3d22a717b111953e80aa4df8a59227086a2d2bcb196
  SHA256_Linux-arm64 3959e9542480cf65b0ca265f131b934641824ed92fac38df3b8bc401f54b02ad
  SHA256_Linux 8cc51f5a86c75ed83956ede8e5aae6f076f213697009741765a5d402af3d4496
  SHA256_win64 0b59fc70300618ebc6a4eaf01fc63a41d43e37e003317cf1db68270674f9d171
  )
set(xp_wirehair REPO github.com/externpro/wirehair TAG v23.12.02.1
  BASE v23.12.02 BRANCH dev
  WEB "https://github.com/catid/wirehair" UPSTREAM "github.com/catid/wirehair"
  DESC "fast and portable fountain codes in C"
  LICENSE "[BSD-3-Clause](https://github.com/catid/wirehair/blob/master/LICENSE 'BSD 3-Clause New or Revised License')"
  SHA256_Darwin-arm64 2950704bfd0b032b01a91a6c2c3397954b45047cdc25f33228105e186097631e
  SHA256_Linux-arm64 6d691b82afc5bba40ba778b78b07f7e69b7bf6b3c5be92552bc8b8b766715601
  SHA256_Linux bea56e35e2292b620532aab17058165e968c53c37bd7e6e660c7c4e1394d7f94
  SHA256_win64 c768565e46ac9aa99e04d19be7f84b6572dd389c741683769e4f4ffc01a75dd5
  )
set(xp_wxwidgets REPO github.com/externpro/wxWidgets TAG v3.1.0.4
  BASE v3.1.0 BRANCH dev
  WEB "http://wxwidgets.org/" UPSTREAM "github.com/wxWidgets/wxWidgets"
  DESC "Cross-Platform C++ GUI Library"
  LICENSE "[wxWindows](https://wxwidgets.org/about/licence/ 'essentially LGPL with an exception')"
  SHA256_Darwin-arm64 07dc8dbe092ab571f9bb9ae516928d1fd1332fb95039803762b9a6800163961b
  SHA256_Linux-arm64 3aa976368873cf4ac75b39bdc95ed4a51b738bcd7f4dda5afc165601e7c55138
  SHA256_Linux dc64796117024eb2dcbb7368d2373cb51d98c7d71d21982af1f07c9fdb5604e5
  SHA256_win64 12018b44ff8615dd5f89808649303804b0afb8b35a21dca8486fff5ebde95429
  )
set(xp_wxcmake REPO github.com/externpro/wxcmake
  BASE wx0 BRANCH dev
  WEB "https://github.com/externpro/wxcmake 'wxcmake repo on github'"
  DESC "build wxWidgets via cmake [submodule of: _wxwidgets_]"
  LICENSE "[wxWindows](https://wxwidgets.org/about/licence/ 'same as wxWidgets license')"
  )
set(xp_yasm REPO github.com/externpro/yasm TAG v1.3.0.1
  BASE v1.3.0 BRANCH dev
  WEB "http://yasm.tortall.net/" UPSTREAM "github.com/yasm/yasm"
  DESC "assembler and disassembler for the Intel x86 architecture"
  LICENSE "[BSD-2-Clause](https://github.com/yasm/yasm/blob/v1.3.0/COPYING 'BSD 2-Clause Simplified License')"
  SHA256_Darwin-arm64 683982fde538e42b0b4ac9555778003c46363780ab91ecdf4154a6948db1cd3e
  SHA256_Linux-arm64 c92da80fae4cd9cfe5da16b9e4e87ddcd2023904f5078e230f33ca0d258e366b
  SHA256_Linux a6821e5b56afae7dd01341954aee5f911a419f74635149c66217c6384fb101dd
  SHA256_win64 a4c7249a4d4812251e8925c4b8fbc5e01e8af141acce9ae9aad7728b488751d6
  )
set(xp_zlib REPO github.com/externpro/zlib TAG v1.3.1.1
  BASE v1.3.1 BRANCH dev
  WEB "https://zlib.net 'zlib website'" UPSTREAM "github.com/madler/zlib"
  DESC "compression library"
  LICENSE "[permissive](https://zlib.net/zlib_license.html 'zlib/libpng license, see https://en.wikipedia.org/wiki/Zlib_License')"
  SHA256_Darwin-arm64 abf7c8fb138a222999b3ea40c20520dd9411c5bbbd75183cd479b6452bb2f127
  SHA256_Linux-arm64 b2acb61a5fd45f17e1ae75d28550260d6fd8454c600b20abb5f59eb5471555b5
  SHA256_Linux c6b382c1586f8820e04fd1e298086e391797f54e6369d770e9256b51c35a58d7
  SHA256_win64 41bd417795e6349e0cb71c6097d2c71ef1e30d274d0be0f1311e891e1f105749
  )
### depend on previous group
set(xp_boost REPO github.com/externpro/boost TAG v1.76.0.2
  BASE boost-1.76.0 BRANCH dev DEPS bzip2 zlib
  WEB "http://www.boost.org/ 'Boost website'" UPSTREAM "github.com/boostorg/boost"
  DESC "libraries that give C++ a boost"
  LICENSE "[BSL-1.0](http://www.boost.org/users/license.html 'Boost Software License')"
  SHA256_Darwin-arm64 ab0a1119f42fe8be6334c92f8a60cf6bd45ad61a1e28fd345b1886ffb7de6d11
  SHA256_Linux-arm64 6b0cdc88b6b7dab256330a404900da205f5833d6d5df80897a27ddf7824ccddd
  SHA256_Linux 1a010b8370020656effe722b88c01ace36255b8ecb5a1aeeda76c41bddb21c4e
  SHA256_win64 40d22b0e708c723d1bb3a2940522ccbd435117f9e9d9525af687f99004fd5bd6
  )
set(xp_ceres-solver REPO github.com/externpro/ceres-solver TAG v2.2.0.2
  BASE 2.2.0 BRANCH dev DEPS eigen
  WEB "http://ceres-solver.org" UPSTREAM "github.com/ceres-solver/ceres-solver"
  DESC "C++ library for modeling and solving large, complicated optimization problems"
  LICENSE "[BSD-3-Clause](http://ceres-solver.org/license.html 'BSD 3-Clause New or Revised License')"
  SHA256_Darwin-arm64 a34baea1b11de9550e21e0f0b7524961dd74b7a17369d7be18e64048a1d973c1
  SHA256_Linux-arm64 06b6429c573e3b3266794c4ceac5501e8a1c0ffa3d430fce11bb9df39b8701f2
  SHA256_Linux 7497798658fa914227d81f7b409705aa143f4ed2b3ee028e74f4894566807703
  SHA256_win64 ccb00129f23e457b92435ca95f09fb56b25f29275eb750b8c722c7d9db21da40
  )
set(xp_libgeotiff REPO github.com/externpro/libgeotiff TAG v1.2.4.2
  BASE 1.2.4 BRANCH dev DEPS wxwidgets
  WEB "http://trac.osgeo.org/geotiff/ 'GeoTIFF trac website'" UPSTREAM "github.com/OSGeo/libgeotiff"
  DESC "georeferencing info embedded within TIFF file"
  LICENSE "[MIT](https://github.com/OSGeo/libgeotiff/blob/master/libgeotiff/LICENSE 'MIT License or public domain')"
  SHA256_Darwin-arm64 2a7cfa1d78c1200963d2a3cf2178a7d1e1e4cc70c7b35d4c29bc1e2cc189ff2a
  SHA256_Linux-arm64 17d89a8ec4b758894df9d0197547e811fb36fcce7031a7a7dffd25f582b2c2ef
  SHA256_Linux f8e3fdb6354b0c61eac50168c8823e6fb58bdb025964faa45c21f5ed9f6c5e5e
  SHA256_win64 8062b2f4a58a9747e981498cd5f251b8988ba493839162ae702b5af5ffc602b0
  )
set(xp_hdf5 REPO github.com/externpro/hdf5 TAG v1.14.6.5
  BASE hdf5_1.14.6 BRANCH dev DEPS zlib
  WEB "https://www.hdfgroup.org/solutions/hdf5/" UPSTREAM "github.com/HDFGroup/hdf5"
  DESC "Utilize the HDF5 high performance data software library and file format to manage, process, and store your heterogeneous data. HDF5 is built for fast I/O processing and storage."
  LICENSE "[BSD-3-Clause](https://github.com/HDFGroup/hdf5/blob/develop/LICENSE 'BSD 3-Clause New or Revised License')"
  SHA256_Darwin-arm64 0e3b00aa64b989fc55047a01ac278a6938c22324394ea28e2173bbdccecc6d91
  SHA256_Linux-arm64 a008859feae11aefbf9d475c62250b6ba44d5435b87a3ff110f8e90bd9ef3988
  SHA256_Linux 8665645ce59162219df17b168e20b081d0b1224cc453322fd7aae13c9352fb34
  SHA256_win64 3cbefc592730f8999897efc1b2c14930ed8f58549afe048f521e041930d471da
  )
set(xp_librttopo REPO github.com/externpro/librttopo TAG v1.1.0.3
  BASE librttopo-1.1.0 BRANCH dev DEPS geos
  WEB "https://git.osgeo.org/gitea/rttopo/librttopo" UPSTREAM "github.com/CGX-GROUP/librttopo"
  DESC "RT Topology Library exposes an API to create and manage standard topologies using user-provided data stores"
  LICENSE "[GPL-2.0](https://github.com/CGX-GROUP/librttopo/blob/master/COPYING 'GNU General Public License v2.0 or later')"
  SHA256_Darwin-arm64 9c90b0a8c6d4caeebbe7417ab7f4d346bb0607a070646b0ad568ed8b6e403246
  SHA256_Linux-arm64 9ea762f2678c6ab0c12b9ddb4ad9db8d8012f7eda6abcfd6d0d587fb224391e4
  SHA256_Linux b62d3ba801f5d90086575a7947558c39b1629b9a90cc32d5df977ef9b706d729
  SHA256_win64 5f821543ffa68e59c3a1c075cbd94be3ebb3409b5aab7be3eb8af9f43a571209
  )
set(xp_libspatialite REPO github.com/externpro/libspatialite TAG v5.1.0.6
  BASE 5.1.0 BRANCH dev DEPS geos libiconv sqlite3 zlib
  WEB "https://www.gaia-gis.it/fossil/libspatialite/home"
  DESC "extends capabilities of SQLite, enabling ti to handle spatial data and perform spatial queries"
  LICENSE "[MPL-1.1](https://www.gaia-gis.it/fossil/libspatialite/home 'MPL tri-license: choose MPL-1.1, GPL-2.0-or-later, LGPL-2.1-or-later')"
  SHA256_Darwin-arm64 92f377721915436b02361a8e704f89f755e53e91b23913ebdd1a57ed4fd9a069
  SHA256_Linux-arm64 f8829df95ddade662ad14f7006809a6c75be5cabfb7f51ffcd2a05edfcf72e47
  SHA256_Linux 00549a7292e6f0391d585c1de642b142d0cb36f67bd01391fc0f89f6c622c506
  SHA256_win64 cb744298b24539e1cad2cb17db9909bbc9ee209bf34c018049b7a42ab767f832
  )
set(xp_libzmq REPO github.com/externpro/libzmq TAG v4.3.4.2
  BASE v4.3.4 BRANCH dev DEPS sodium
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/libzmq"
  DESC "high-performance asynchronous messaging library"
  LICENSE "[MPL-2.0](http://wiki.zeromq.org/area:licensing 'Mozilla Public License 2.0')"
  SHA256_Darwin-arm64 8f4dd694dbec18ee51d37f10221b437c3246f78dc30f92822219ab6e678220f4
  SHA256_Linux-arm64 a9d698de563710b5139815a39a04134816be7eeba760d2d85abde10c8919c523
  SHA256_Linux b010329f58e199ffb01f3fbd016d4ed9acc2ce304c526162c75ea96bad870c05
  SHA256_win64 24ee926b65966edceaba9e7df7a25885cee636f4b01b15c6b70744aacbcfe2a6
  )
set(xp_node-addon-api REPO github.com/externpro/node-addon-api TAG v8.5.0.1
  BASE v8.5.0 BRANCH dev DEPS nodexp
  WEB "https://github.com/nodejs/node-addon-api" UPSTREAM "github.com/nodejs/node-addon-api"
  DESC "Module for using N-API from C++"
  LICENSE "[MIT](https://github.com/nodejs/node-addon-api/blob/v8.5.0/LICENSE.md 'MIT License')"
  SHA256_Darwin-arm64 fcb719626222afcccf912c87c44c7aa7bc3ab673e627471b260af28698d6270b
  SHA256_Linux-arm64 2c084a7833644cbb1f510b0699572f873b9edbfd9b030a59098a3b58a4bdfe66
  SHA256_Linux 2a9b1ada4a0df02333e4204194c8449be23f136d92d25a583a9c3fb4b1c8489c
  SHA256_win64 8cb379185c546648d8f23ea12247919294db4229e2d05a486a4f72a911ac1d49
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
set(xp_spdlog REPO github.com/externpro/spdlog TAG v1.15.3.1
  BASE v1.15.3 BRANCH dev DEPS fmt
  WEB "https://github.com/gabime/spdlog/wiki" UPSTREAM "github.com/gabime/spdlog"
  DESC "Fast C++ logging library"
  LICENSE "[MIT](https://github.com/gabime/spdlog?tab=License-1-ov-file 'MIT License')"
  SHA256_Darwin-arm64 1048b57b1a6506b47d7d97c2cf3b96422e5eb4d9736b9e49fe84a4beaf7b9d6b
  SHA256_Linux-arm64 118cb9acbc0c7f34c87b2c9b16a3c4a9f6aa086f6226e51e22d2f0f959337000
  SHA256_Linux a79a4cfb510a9080f920a84ed88d47499a2662dcd4f0a22d296966d63738d5c9
  SHA256_win64 8812951049a04c5c9ab4e7d24de1ba6b9fca029e892da81f9429ac214f875014
  )
set(xp_wxx REPO github.com/externpro/wxx TAG v25.01
  BASE v0 BRANCH dev DEPS wxwidgets
  WEB "https://github.com/externpro/wxx"
  DESC "wxWidget-based extra components"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  SHA256_Darwin-arm64 e560e75c34a6556300ce39a878a69af1c09c57d0c2689a60506aaf29bd61a99d
  SHA256_Linux-arm64 fa37c7d8e52527c2c1c50e3fef701600df3faa83ac849f5df72993aff8e269aa
  SHA256_Linux 996e5200e2c3bc3f447a60b34621ea3c95818cab8d59fb134aaf2d765190bf82
  SHA256_win64 ed8c03460ffbdd66bdede8afc2b6b71c296adab2351a7128851745599a449f54
  )
set(xp_wxplotctrl REPO github.com/externpro/wxplotctrl
  BASE v2006.04.28 BRANCH dev
  WEB "https://sourceforge.net/projects/wxcode/files/Components/wxPlotCtrl/"
  DESC "interactive xy data plotting widgets [submodule of: _wxx_]"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
set(xp_wxthings REPO github.com/externpro/wxthings
  BASE v2006.04.28 BRANCH dev
  WEB "https://sourceforge.net/projects/wxcode/files/Components/wxThings/"
  DESC "a variety of data containers and controls [submodule of: _wxx_]"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
set(xp_wxtlc REPO github.com/externpro/wxTLC
  BASE v1208 BRANCH dev
  WEB "https://sourceforge.net/projects/wxcode/files/Components/treelistctrl/"
  DESC "a multi column tree control [submodule of: _wxx_]"
  LICENSE "[wxWindows](http://wxcode.sourceforge.net/ 'wxWindows Library License')"
  )
set(xp_wxtetris REPO github.com/smanders/wxTetris TAG v1.2.0
  BASE v0 BRANCH dev EXE_DEPS wxwidgets
  WEB "https://github.com/smanders/wxTetris"
  DESC "wxWidgets Tetris game"
  LICENSE "[MIT](https://github.com/smanders/wxTetris/blob/dev/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 6aeace636c56f72746cef5acefe98ca859b14243f6178bc49fb4bbac2574af72
  SHA256_Linux-arm64 a2543dfcb6d3343724b3fed6f8cab70efd0631af30ede45443f91de6d5533008
  SHA256_Linux 984ed430f611b8bf03323902fa33a04ef8a28fc704fd5c32917bb26fe3912057
  SHA256_win64 b457f46b71d1787eb9e70fd5cf1ff16386937c53b021f5b70db79b2b61755ad7
  )
### depend on previous group
set(xp_activemqcpp REPO github.com/externpro/activemq-cpp VER 3.9.5 XP_MODULE
  BASE apache:activemq-cpp-3.9.5 BRANCH xp-3.9.5 DEPS apr openssl
  WEB "http://activemq.apache.org/cms/" UPSTREAM "github.com/apache/activemq-cpp"
  DESC "ActiveMQ C++ Messaging Service (CMS) client library"
  LICENSE "[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0.html 'Apache License, Version 2.0')"
  )
set(xp_azmq REPO github.com/externpro/azmq TAG v1.0.3.1
  BASE v1.0.3 BRANCH dev DEPS boost libzmq
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/azmq"
  DESC "provides Boost Asio style bindings for ZeroMQ"
  LICENSE "[BSL-1.0](https://github.com/zeromq/azmq/blob/master/LICENSE-BOOST_1_0 'Boost Software License 1.0')"
  SHA256_Darwin-arm64 2951835ea4dd24d11d1d922212cb65319d2925641ce5beb4cd01363bf9a8c719
  SHA256_Linux-arm64 3ff2ab1995e7ee9c954c7a8c2bebdf1ebf75dd87bda7d885762271948ddc503e
  SHA256_Linux 33b12c2408f41480d47e4415ab6d9564d1d2c3da42913dbe2e6a5b8475723bac
  SHA256_win64 3d3c92b9da136dcafec91ebc728743219d55a5be30cfa53d71bc3c56a2d81201
  )
set(xp_cppzmq REPO github.com/externpro/cppzmq VER 4.7.1 XP_MODULE
  BASE zeromq:v4.7.1 BRANCH xp4.7.1 DEPS libzmq
  WEB "https://zeromq.org/" UPSTREAM "github.com/zeromq/cppzmq"
  DESC "header-only C++ binding for libzmq"
  LICENSE "[MPL-2.0](http://wiki.zeromq.org/area:licensing 'Mozilla Public License 2.0')"
  )
set(xp_fecpp REPO github.com/externpro/fecpp TAG v0.9.1
  BASE v0.9 BRANCH dev EXE_DEPS boost
  WEB "http://www.randombit.net/code/fecpp/" UPSTREAM "github.com/randombit/fecpp"
  DESC "C++ forward error correction with SIMD optimizations"
  LICENSE "[BSD-2-Clause](http://www.randombit.net/code/fecpp/ 'BSD 2-Clause Simplified License')"
  SHA256_Darwin-arm64 a83651a12a7e5b04897fdf3668c55397e4691359b4054a9c852fc967f14bb083
  SHA256_Linux-arm64 e50474c0fb088d2551070ae554566a60adaafaee832c3c3f139ca86fe0335310
  SHA256_Linux ef1a3f8db144a49fde390bcaa2d6b137c764cd23880a365c94702d14f3bc31d1
  SHA256_win64 90951863a61b1a7196caf00a66127736b5c9e7be003c4b4cc93c5c0a60dd73ad
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
set(xp_libstrophe REPO github.com/externpro/libstrophe TAG v0.9.1.2
  BASE 0.9.1 BRANCH dev DEPS expat openssl
  WEB "http://strophe.im/libstrophe/" UPSTREAM "github.com/strophe/libstrophe"
  DESC "A simple, lightweight C library for writing XMPP client"
  LICENSE "[MIT or GPL-3.0](https://github.com/strophe/libstrophe/blob/0.9.1/LICENSE.txt 'dual licensed under MIT and GPLv3 licenses')"
  SHA256_Darwin-arm64 08e1b10b41e38d8bb2242849733c3b6bb0f146e9e66a58923ad2dd5a2994acd9
  SHA256_Linux-arm64 c5ff401cb9a96001d4f4d7681bf33a811737270e258263b00d718956c2685fd7
  SHA256_Linux e3c847890d4ff3c3755abd0eb5e198233f2795be883971fc9edb7e86cbf328c8
  SHA256_win64 492a26d7628b28151b4d12cbf3679bebe8e8fabb7a2827eb1ebbb71bae7cc4e0
  )
set(xp_spatialite-tools REPO github.com/externpro/spatialite-tools TAG v5.1.0.5
  BASE 5.1.0a BRANCH dev EXE_DEPS libspatialite
  WEB "https://www.gaia-gis.it/fossil/spatialite-tools/index"
  DESC "collection of open source Command Line Interface (CLI) tools supporting SpatiaLite"
  LICENSE "[GPL-3.0](https://www.gaia-gis.it/fossil/spatialite-tools/index 'GPL-3.0-or-later')"
  SHA256_Darwin-arm64 b6e093fc07be5d28485d68423599ef26dd3cbb550e050200af3d2a0e9bace314
  SHA256_Linux-arm64 46811c4d122e1ba8c00ea2e2d3cb1495ed763804fb4ea9b4499eb7338bb85fd7
  SHA256_Linux 14d9e25006371d2c64e866a0a021eaa721dad410bb8a5125a5019d09e1aee2a3
  SHA256_win64 1f3b86512e2f2a0b218a2db1eefddf121132304ac45f535b7d53940459b0214a
  )
set(xp_wxinclude REPO github.com/externpro/wxInclude TAG v1.2.1
  BASE v1.0 BRANCH dev EXE_DEPS boost
  WEB "http://wiki.wxwidgets.org/Embedding_PNG_Images"
  DESC "embed resources into cross-platform code"
  LICENSE "[wxWindows](http://wiki.wxwidgets.org/Embedding_PNG_Images 'assumed wxWindows license, since source can be downloaded from wxWiki')"
  SHA256_Darwin-arm64 554f46a0f13ce7d95871032f5dc2c68bd2f52104ba01d602b90fd2b61ec7987a
  SHA256_Linux-arm64 cc3f86ad91f519407c8fdda2ca9a0df6b374085fbfc73cce086d6f166974d7f6
  SHA256_Linux 3ce88bcb0204b5b5382a3445f849fb2eb0eaa8a7c67d2befb8492f5395bc9a8d
  SHA256_win64 7c71aa6993197210ea2410f2e1447ae66b0d6ea834f481b9e49e05905de3e71e
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
