set(xp_activemq-cpp REPO github.com/externpro/activemq-cpp TAG v3.9.5.2
  MANIFEST_SHA256 0151453f6b0031ad4c59a0b79719b2e97464a0fb72125399feeb512246195f9b
  )
set(xp_apr REPO github.com/externpro/apr TAG v1.7.6.2
  MANIFEST_SHA256 0d2ebd3964c5965120615d5cd920902abe6447b3f5fa1118ac87d67506571fa7
  )
set(xp_argon2 REPO github.com/externpro/argon2 TAG v20210625.1
  XPBLD "intro" BASE 20210625
  WEB "https://www.password-hashing.net" UPSTREAM "github.com/P-H-C/phc-winner-argon2"
  DESC "The reference C implementation of the Argon2, the password-hashing function that won the Password Hashing Competition (PHC)"
  LICENSE "[CC0-1.0 or Apache-2.0](https://github.com/P-H-C/phc-winner-argon2/blob/master/LICENSE 'dual licensed under Creative Commons Zero v1.0 Universal and Apache License, Version 2.0')"
  SHA256_Darwin-arm64 1682cf01eb81cd6131dd47f9d4e7799b594882bda5f1f034cd52939134c2d03a
  SHA256_Linux-arm64 55587523e38ac32ad52500f0c374505f16caec80c92c231ab1e8b7ed432ee2d3
  SHA256_Linux ea7a773da6aca9ec9766e6a1ae680b9375c068375bb2fdaee959745a4190a69c
  SHA256_win64 fa649f8c8975985f9714f11c500aef67468fc66801611aa067bbb489e9814da2
  )
set(xp_azmq REPO github.com/externpro/azmq TAG v1.0.3.2
  MANIFEST_SHA256 64c7699cc04af1e663be4f4d80a2a892c023f4aa1a4a92b96c512201fd002a06
  )
set(xp_boost REPO github.com/externpro/boost TAG v1.76.0.4
  MANIFEST_SHA256 9d6e095819fb155829b034759006e9aef3d7c4a761e5b0c9d1ebfa31064d5d7c
  )
set(xp_bzip2 REPO github.com/externpro/bzip2 TAG v1.0.8.3
  MANIFEST_SHA256 894cfae3e809b37ccbba4d54b499d6d57fa0c8d4a2e17bb11c6765cd6885d92d
  )
set(xp_c-ares REPO github.com/externpro/c-ares TAG v1.18.1.2
  MANIFEST_SHA256 8143097360c9312f0b0d015f251158e5a583be6d4d6184f41f3bac70c9878b12
  )
set(xp_ceres-solver REPO github.com/externpro/ceres-solver TAG v2.2.0.2
  XPBLD "patch" BASE 2.2.0 DEPS eigen
  WEB "http://ceres-solver.org" UPSTREAM "github.com/ceres-solver/ceres-solver"
  DESC "C++ library for modeling and solving large, complicated optimization problems"
  LICENSE "[BSD-3-Clause](http://ceres-solver.org/license.html 'BSD 3-Clause New or Revised License')"
  SHA256_Darwin-arm64 a34baea1b11de9550e21e0f0b7524961dd74b7a17369d7be18e64048a1d973c1
  SHA256_Linux-arm64 06b6429c573e3b3266794c4ceac5501e8a1c0ffa3d430fce11bb9df39b8701f2
  SHA256_Linux 7497798658fa914227d81f7b409705aa143f4ed2b3ee028e74f4894566807703
  SHA256_win64 ccb00129f23e457b92435ca95f09fb56b25f29275eb750b8c722c7d9db21da40
  )
set(xp_clang-format REPO github.com/externpro/clang-format TAG v19.1.5.1
  XPBLD "fetch" BASE v0
  WEB "https://clang.llvm.org/docs/ClangFormat.html" UPSTREAM "github.com/llvm/llvm-project"
  DESC "used to format C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C# code (clang/tools/clang-format in upstream repo)"
  LICENSE "[Apache-2.0](https://releases.llvm.org/11.0.0/LICENSE.TXT 'Apache License v2.0 with LLVM Exceptions, see https://clang.llvm.org/features.html#license and https://llvm.org/docs/DeveloperPolicy.html#copyright-license-and-patents')"
  SHA256_Darwin-arm64 5d3559dce45e20b32a64e19e63ef9aee6b6385c8869ab00d8d49e60e85021e72
  SHA256_Linux-arm64 10bc83ac98e7e7090c57a1dc66722ef5b77d6902b4b8b5d94b3e08dec79eed73
  SHA256_Linux 5ee07eddc025462bcfaa44e32547b43951ee03099b13b789866d0047a47e5524
  SHA256_win64 c75c1d540ff8ed273b140c2e2c6f13bc978a65539d57c6e35ec001e149d85b89
  )
set(xp_cppzmq REPO github.com/externpro/cppzmq TAG v4.7.1.2
  MANIFEST_SHA256 3c4a5d3793906fd121562e7ce063f1977e90b8df079ae80749914f989c9be51b
  )
set(xp_curl REPO github.com/externpro/curl TAG v7.80.0.2
  MANIFEST_SHA256 97b813cc7a7c3a403bccb5f33225f5940f26f64e97147098f19e27efedbcd5a5
  )
set(xp_eigen REPO github.com/externpro/eigen TAG v3.4.0.1
  XPBLD "patch" BASE 3.4.0
  WEB "http://eigen.tuxfamily.org" UPSTREAM "gitlab.com/libeigen/eigen.git"
  DESC "C++ template library for linear algebra"
  LICENSE "[MPL-2.0](http://eigen.tuxfamily.org/index.php?title=Main_Page#License 'Mozilla Public License 2.0')"
  SHA256_Darwin-arm64 28d72a94b2c5c4ef2786c2847c1d69d7e9d3c52d080b15339a2d93edcffa36c7
  SHA256_Linux-arm64 235f7a351de94000ad7e2b46fe8f1f503c86ffb573d40a5d27377964d374299f
  SHA256_Linux 78a03eb8d1b3b6161b3d2de440172e456a13723cc9ae4730df5933589167f46e
  SHA256_win64 9bec874c71af9d899e0ab68f470d1ed2208004178a400ea04babe803358995cf
  )
set(xp_fecpp REPO github.com/externpro/fecpp TAG v0.9.2
  MANIFEST_SHA256 c177c19ef10be21fd1dd9bda8a20f21cb397dca7ca1e41f6cc7fbaf77d07ad50
  )
set(xp_ffmpeg REPO github.com/externpro/FFmpeg TAG v4.3.1.1
  XPBLD "native(unix)" BASE n4.3.1 DEPS openh264 yasm
  WEB "https://www.ffmpeg.org/" UPSTREAM "github.com/FFmpeg/FFmpeg"
  DESC "complete, cross-platform solution to record, convert and stream audio and video (pre-release: no windows package)"
  LICENSE "[LGPL-2.1](https://www.ffmpeg.org/legal.html 'LGPL version 2.1 or later')"
  SHA256_Darwin-arm64 e6eaa0d3bdb1c2b381306a19f6597ae8c79ad8d98e1803d3af0671e695538519
  SHA256_Linux-arm64 7f11c8790f21d67716ea25c5b6b49ba202f8bf9f94e235fa0d5c33cd89dfd225
  SHA256_Linux 5e6121f9471742e37a41080afccbd21c701f601db6a9c6cbce8a8354275af34e
  )
set(xp_ffmpeg REPO github.com/externpro/FFmpeg TAG v2.6.2.2
  XPBLD "bin(msw), native(unix)" BASE n2.6.2 DEPS openh264 yasm
  WEB "https://www.ffmpeg.org/" UPSTREAM "github.com/FFmpeg/FFmpeg"
  DESC "complete, cross-platform solution to record, convert and stream audio and video"
  LICENSE "[LGPL-2.1](https://www.ffmpeg.org/legal.html 'LGPL version 2.1 or later')"
  SHA256_Darwin-arm64 6624fbdca192d88f0e163f36e47d19a1aa2286beeec630285bed242475f2db84
  SHA256_Linux-arm64 7f84e517475d6dc6fb139d826f578eaf128719327ff44e35bf8272f17dc65953
  SHA256_Linux 8ba9439fff1f92e34d84cc45fc12699e47ce148b2e3f9680dffb105f7611fafa
  SHA256_win64 79399ed5b6ad4361ae629aeeb861fb71d0691fb4f34fe04ef27d91edeb5c0a8e
  )
set(xp_flatbuffers REPO github.com/externpro/flatbuffers TAG v25.2.10.1
  XPBLD "patch" BASE v25.2.10
  WEB "http://google.github.io/flatbuffers/" UPSTREAM "github.com/google/flatbuffers"
  DESC "efficient cross platform serialization library"
  LICENSE "[Apache-2.0](https://github.com/google/flatbuffers/blob/v25.2.10/LICENSE 'Apache License, Version 2.0')"
  SHA256_Darwin-arm64 16bacbf0607ff852a8c6d5d13464d73eb377db2e792cc68b63806b580f5120ec
  SHA256_Linux-arm64 8f77592551594a04ee8d2f85cf9164ad1c39ffed3bf3f9dba82cadaec82271b2
  SHA256_Linux 952061515c851ce9c89500a7311a72d7d7494627dc52f588a66df76d386adf5e
  SHA256_win64 650f5866d26ad36f06166b18f371dd46c76ee2c68dd7f094fcefb77d347d60a8
  )
set(xp_fmt REPO github.com/externpro/fmt TAG v11.2.0.7
  MANIFEST_SHA256 a91f44f9147ea00163676f3f43099a4d522b2fc7c8f8a5a9742845ad3f552bb2
  )
set(xp_geos REPO github.com/externpro/geos TAG v3.13.0.5
  MANIFEST_SHA256 d12a0ac3a9d39f45af369952673c9e94c232528f5cf45cfa7c21b8d85a9a9ee3
  )
set(xp_geotranz REPO github.com/externpro/geotranz TAG v2.4.2.1
  XPBLD "intro" BASE v2.4.2
  WEB "https://earth-info.nga.mil"
  DESC "geographic translator (convert coordinates)"
  LICENSE "[public domain](https://github.com/externpro/geotranz 'see GEOTRANS Terms of Use in README or download https://earth-info.nga.mil/php/download.php?file=wgs-terms')"
  SHA256_Darwin-arm64 35bc276cafb52bacf1b232c36a990e709a1a6bebad066c4a8e657b4026149af5
  SHA256_Linux-arm64 52afe07b245405d7c7ec093c68377cf2eec636268ca40b7b536536b212aec688
  SHA256_Linux 22aa67e65c8c9034ae060fd34a09238328bfc9a55d1bfd4b6d4d6b0bef03fb2e
  SHA256_win64 687cee720040645ba293d51c2c8d1353fd256fe9e7058198324493f9dbc7db2b
  )
set(xp_glew REPO github.com/externpro/glew TAG v1.13.0.1
  XPBLD "patch" BASE glew-1.13.0
  WEB "http://glew.sourceforge.net" UPSTREAM "github.com/nigels-com/glew"
  DESC "The OpenGL Extension Wrangler Library"
  LICENSE "[MIT](https://github.com/nigels-com/glew/blob/master/LICENSE.txt 'Modified BSD, Mesa 3D (renamed X11/MIT), Khronos (renamed X11/MIT)')"
  SHA256_Darwin-arm64 b5546d5d186746ed62f5ef64176fa28880a31286fa060159d7872e22a0ebff81
  SHA256_Linux-arm64 9b75c245b7ae8120203f4fcc639380adecfe7d0b749462823bfe87bffe278d42
  SHA256_Linux de5619809f5b7f9e44c6b8b7dab814ff44a78aa1b82bdf7798b7e8229f4a23ad
  SHA256_win64 dd82830539c47e4933e59664108ac84472130482bfab25e651c3140240f711bc
  )
set(xp_googletest REPO github.com/externpro/googletest TAG v1.16.0.2
  MANIFEST_SHA256 3442fd80e8cb8bb0cdd300ef312d3c4a79b8d067e614f4a66ea7d511e6da96df
  )
set(xp_hdf5 REPO github.com/externpro/hdf5 TAG v1.14.6.6
  MANIFEST_SHA256 8b32eb66af6242edce23bafe3e4f283b93434e6434d4a4a9a1144ccfa7dda28c
  )
set(xp_jasper REPO github.com/externpro/jasper TAG v1.900.1.1
  XPBLD "auto" BASE version-1.900.1
  WEB "https://jasper-software.github.io/jasper/" UPSTREAM "github.com/jasper-software/jasper"
  DESC "JasPer is a software toolkit for the handling of image data. It was initially developed as a reference implementation of the JPEG 2000 Part-1 codec."
  LICENSE "[JasPer-2.0](https://github.com/jasper-software/jasper/blob/master/LICENSE.txt 'JasPer software license based on MIT License')"
  SHA256_Darwin-arm64 59acfce4e6bd7b2de6facae10fd086f137e567e13dc925bcfe289d7355525ee3
  SHA256_Linux-arm64 c3de594a78c3c97178e582ee353d1cadb4fb9d337a42eae86fc75861d6881521
  SHA256_Linux 0f6ac4aade72a0d0cbecbd5cdd4113486051edfc99516927fd0f33e632a68378
  SHA256_win64 a3c516004b010fd280c342e1c3f42bed9b1752b6b47bb3882d40d62315a2c56b
  )
set(xp_jpegxp REPO github.com/externpro/jpegxp TAG v6.25.1
  XPBLD "intro" BASE jxp.240125
  WEB "http://www.ijg.org/"
  DESC "JPEG codec with mods for Lossless, 12-bit lossy (XP)"
  LICENSE "[IJG](https://github.com/externpro/libjpeg/blob/upstream/README 'Independent JPEG Group License, see LEGAL ISSUES in README')"
  SHA256_Linux 13f5b648a9d7cf63017521541241a8476da27f0197f3952c28904aa45975df60
  SHA256_Linux-arm64 48cc74c37ade055d45a2b8b6b0e5e73a8f58222ae88565956272811c5519077a
  SHA256_win64 2a18e83a8f670a1dfaa89f821f31e8886adb82e8627c2e68c029f9d17cb0013b
  SHA256_Darwin-arm64 88f6659543c0ab6a88c48007262e35a6253aa245dacd33c44dcbfa2b99a2a93c
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
  XPBLD "intro" BASE v2019.10.9
  WEB "https://github.com/4creators/jxrlib" UPSTREAM "github.com/4creators/jxrlib"
  DESC "JPEG XR Image Codec reference implementation library released by Microsoft"
  LICENSE "[BSD-2-Clause](https://github.com/4creators/jxrlib/blob/master/LICENSE 'BSD 2-Clause Simplified License')"
  SHA256_Darwin-arm64 42a7f5889774f4ba141b59ef3bbfa7ca27928a19238163273a3c2d53983a7f59
  SHA256_Linux-arm64 bbd1e172e91e77598a47f48d5b950b7c7417180268e92590f0674be50cbb9f93
  SHA256_Linux 2e79d179fb0ae0ee5347f346bc017f7f94240f79af241aeb90dd520451d57d49
  SHA256_win64 505f1984cd8950cf1d4a52a95b76340c334632318cb59e83ba05fac7d6050df0
  )
set(xp_libexpat REPO github.com/externpro/libexpat TAG v2.2.5.2
  MANIFEST_SHA256 f0ea1c3300bc4a033343189b33698c23fdbb3f8808247c844f450e0e3126718b
  )
set(xp_libgeotiff REPO github.com/externpro/libgeotiff TAG v1.2.4.2
  XPBLD "intro" BASE 1.2.4 DEPS wxwidgets
  WEB "http://trac.osgeo.org/geotiff/ 'GeoTIFF trac website'" UPSTREAM "github.com/OSGeo/libgeotiff"
  DESC "georeferencing info embedded within TIFF file"
  LICENSE "[MIT](https://github.com/OSGeo/libgeotiff/blob/master/libgeotiff/LICENSE 'MIT License or public domain')"
  SHA256_Darwin-arm64 2a7cfa1d78c1200963d2a3cf2178a7d1e1e4cc70c7b35d4c29bc1e2cc189ff2a
  SHA256_Linux-arm64 17d89a8ec4b758894df9d0197547e811fb36fcce7031a7a7dffd25f582b2c2ef
  SHA256_Linux f8e3fdb6354b0c61eac50168c8823e6fb58bdb025964faa45c21f5ed9f6c5e5e
  SHA256_win64 8062b2f4a58a9747e981498cd5f251b8988ba493839162ae702b5af5ffc602b0
  )
set(xp_libgit2 REPO github.com/externpro/libgit2 TAG v1.3.0.2
  MANIFEST_SHA256 2b34804488d10631ceb8d6dabaa181e843e697f9e1e35a983787451d64062e20
  )
set(xp_libiconv REPO github.com/externpro/libiconv TAG v1.18.6
  XPBLD "bin" BASE v0
  WEB "https://www.gnu.org/software/libiconv/" UPSTREAM "github.com/pffang/libiconv-for-Windows/releases/tag/1.18-eed6782"
  DESC "character set conversion library"
  LICENSE "[LGPL-2.1](https://savannah.gnu.org/projects/libiconv/ 'LGPL version 2.1')"
  SHA256_Darwin-arm64 8208515a4331ae73483bcbb0a7b718e2a8a4f85caddf857c11a047a3153af392
  SHA256_Linux-arm64 a49a6558cca5bc66050c8034d7120145344a5fcfa98f8859762ca7e32c53622d
  SHA256_Linux 7c24a6ae1fad58ed8560aa3e39f5475483bad27719e51b77ec140a41e0b3d558
  SHA256_win64 2e196d43265bb2af3f419358b686f3a220ca76f08113e2d162dd3b334934985c
  )
set(xp_librttopo REPO github.com/externpro/librttopo TAG v1.1.0.3
  XPBLD "auto" BASE librttopo-1.1.0 DEPS geos
  WEB "https://git.osgeo.org/gitea/rttopo/librttopo" UPSTREAM "github.com/CGX-GROUP/librttopo"
  DESC "RT Topology Library exposes an API to create and manage standard topologies using user-provided data stores"
  LICENSE "[GPL-2.0](https://github.com/CGX-GROUP/librttopo/blob/master/COPYING 'GNU General Public License v2.0 or later')"
  SHA256_Darwin-arm64 9c90b0a8c6d4caeebbe7417ab7f4d346bb0607a070646b0ad568ed8b6e403246
  SHA256_Linux-arm64 9ea762f2678c6ab0c12b9ddb4ad9db8d8012f7eda6abcfd6d0d587fb224391e4
  SHA256_Linux b62d3ba801f5d90086575a7947558c39b1629b9a90cc32d5df977ef9b706d729
  SHA256_win64 5f821543ffa68e59c3a1c075cbd94be3ebb3409b5aab7be3eb8af9f43a571209
  )
set(xp_libsodium REPO github.com/externpro/libsodium TAG v1.0.18.227
  MANIFEST_SHA256 b38e3e769f6cab01568878614a1871743993d6886e563454bea398582d919395
  )
set(xp_libspatialite REPO github.com/externpro/libspatialite TAG v5.1.0.6
  XPBLD "auto" BASE 5.1.0 DEPS geos libiconv sqlite3 zlib
  WEB "https://www.gaia-gis.it/fossil/libspatialite/home"
  DESC "extends capabilities of SQLite, enabling ti to handle spatial data and perform spatial queries"
  LICENSE "[MPL-1.1](https://www.gaia-gis.it/fossil/libspatialite/home 'MPL tri-license: choose MPL-1.1, GPL-2.0-or-later, LGPL-2.1-or-later')"
  SHA256_Darwin-arm64 92f377721915436b02361a8e704f89f755e53e91b23913ebdd1a57ed4fd9a069
  SHA256_Linux-arm64 f8829df95ddade662ad14f7006809a6c75be5cabfb7f51ffcd2a05edfcf72e47
  SHA256_Linux 00549a7292e6f0391d585c1de642b142d0cb36f67bd01391fc0f89f6c622c506
  SHA256_win64 cb744298b24539e1cad2cb17db9909bbc9ee209bf34c018049b7a42ab767f832
  )
set(xp_libssh2 REPO github.com/externpro/libssh2 TAG v1.9.0.3
  MANIFEST_SHA256 44231b54b1b271766cc4c27ae5c0e925042fdd7ea9814da00681e3ae127a7c5e
  )
set(xp_libstrophe REPO github.com/externpro/libstrophe TAG v0.9.1.4
  MANIFEST_SHA256 dd90d3340f7cc1af5abcbaf5973ce0e3f841ee131bd894aa03d56eb33a16390b
  )
set(xp_libzmq REPO github.com/externpro/libzmq TAG v4.3.4.3
  MANIFEST_SHA256 3d928aff851cf38d0fcea8a138f7c2c592d6b3e738fd637d63a0e21ce7ea1fab
  )
set(xp_lua REPO github.com/externpro/lua TAG v5.2.3.1
  XPBLD "patch" BASE v5.2.3
  WEB "http://www.lua.org/" UPSTREAM "github.com/lua/lua"
  DESC "a powerful, fast, lightweight, embeddable scripting language"
  LICENSE "[MIT](http://www.lua.org/license.html 'MIT License')"
  SHA256_Darwin-arm64 598f90f0fc383f056507326dedf44ad7ff75f67480879ec52a67735854de197b
  SHA256_Linux-arm64 d34d2a722900d8035ace261d6cb04bcf2336c24e0cecb542197752c0f755477e
  SHA256_Linux f73fb7d78ea4d66522e660df1dc0e52fa45a97affb92a67497cd75b12758895e
  SHA256_win64 18dd0d950beed3e1df142f77015a0498a50c2292d4b51a0c2844bb8b867d78a9
  )
set(xp_luabridge REPO github.com/externpro/LuaBridge TAG v2.10.3
  XPBLD "patch" BASE 2.10 DEPS lua
  WEB "http://vinniefalco.github.io/LuaBridge/Manual.html 'LuaBridge Reference Manual'" UPSTREAM "github.com/vinniefalco/LuaBridge"
  DESC "a lightweight, dependency-free library for binding Lua to C++"
  LICENSE "[MIT](https://github.com/vinniefalco/LuaBridge/#official-repository 'MIT License')"
  SHA256_Darwin-arm64 af2b632c302c9b71151bf45f1eea651e085dfb8fe831f726062a403e94670e0e
  SHA256_Linux-arm64 86d7cdcbe08b7431efde8d67846bf72b713d231359a96490f6333bf05fbec8c1
  SHA256_Linux 481c33e6497c1b7358ae05aa067441dd5a77d501736cf6a75976f7084bc3ac93
  SHA256_win64 49c01bcfb4ae0c5f64cc43e08d13630209e242136e589726936594fa373e3723
  )
set(xp_nasm REPO github.com/externpro/nasm TAG v2.14.02.3
  MANIFEST_SHA256 f381ee1a2b376fead6cacee9495456ddd9e01818e7184248a523ceb57be9357e
  )
set(xp_nlohmann_json REPO github.com/externpro/nlohmann_json TAG v3.12.0.1
  XPBLD "patch" BASE v3.12.0
  WEB "https://json.nlohmann.me" UPSTREAM "github.com/nlohmann/json"
  DESC "JSON for Modern C++"
  LICENSE "[MIT](https://github.com/nlohmann/json/blob/develop/LICENSE.MIT 'MIT License')"
  SHA256_Darwin-arm64 b5631660b006ccc13f282be4c30f41ddf18ed0f2ab6c56b9c7176377dd51a472
  SHA256_Linux-arm64 be2efc38fd6585c4b50ec8878fe411bc6c443c13d2e60f5192236abf8931703d
  SHA256_Linux 4960bad21fc64c0e05af8879421f1b60c6a5af965e4690641eb9b793474678eb
  SHA256_win64 cbcc1cdb845dda2e5f26d73d77cd66206b28cba03bc22b6dbb43b567d759b528
  )
set(xp_node-addon-api REPO github.com/externpro/node-addon-api TAG v8.5.0.1
  XPBLD "intro" BASE v8.5.0 DEPS nodexp
  WEB "https://github.com/nodejs/node-addon-api" UPSTREAM "github.com/nodejs/node-addon-api"
  DESC "Module for using N-API from C++"
  LICENSE "[MIT](https://github.com/nodejs/node-addon-api/blob/v8.5.0/LICENSE.md 'MIT License')"
  SHA256_Darwin-arm64 fcb719626222afcccf912c87c44c7aa7bc3ab673e627471b260af28698d6270b
  SHA256_Linux-arm64 2c084a7833644cbb1f510b0699572f873b9edbfd9b030a59098a3b58a4bdfe66
  SHA256_Linux 2a9b1ada4a0df02333e4204194c8449be23f136d92d25a583a9c3fb4b1c8489c
  SHA256_win64 8cb379185c546648d8f23ea12247919294db4229e2d05a486a4f72a911ac1d49
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
  XPBLD "bin" BASE v0
  WEB "https://nodejs.org/en/blog/release/v22.19.0/"
  DESC "node executable bundled as externpro devel package to build angular (ng) projects"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v22.19.0/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 30e8956f5a7ef839af9b3b9bf491e16744987a9fdb6b26d832a97c657fd3d51f
  SHA256_Linux-arm64 23d7ce5a243117f4ee2c4b67a1fd90e4e012f7ac732202126c18804b7808b8df
  SHA256_Linux 60210d3228bee5c4f1e75edd6b42fa2a01e1b2d19a8bf6a968ff499984ffcd3f
  SHA256_win64 a3c990d9de9ebb29f4967b10dd9ae66472f8bf37e45c899d80914d5d25d2c890
  )
set(xp_nodexp REPO github.com/externpro/nodexp TAG v22.19.0.1
  XPBLD "bin" BASE v0 # TRICKY: nodexp, openssl versions coordinated
  WEB "https://nodejs.org/en/blog/release/v22.19.0/"
  DESC "node/npm development platform and runtime executable bundled as externpro devel package to build addons"
  LICENSE "[MIT](https://raw.githubusercontent.com/nodejs/node/v22.19.0/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 8041f0516a5f40ad2845e188ceac2aa34f1c08e7229d8e9d0322ba77c734c52b
  SHA256_Linux-arm64 129d55ca8046fab214b8e41278e43fd2e450a497548081424820fcb2828026df
  SHA256_Linux c1c9bf87b6a6eee4010dfcbd8fbca8d8142ca707a53cd6e4617f0a559334014c
  SHA256_win64 220446e3ba9e5aa83bc7e970062922f066e0803bbc78de0e2568dddfaec8dfc7
  )
set(xp_nvjpeg2000 REPO github.com/externpro/nvJPEG2000 TAG v0.8.1.3
  XPBLD "bin" BASE v0
  WEB "https://developer.nvidia.com/nvjpeg"
  DESC "high-performance GPU-accelerated library for decoding JPEG 2000 format images (not available on macOS)"
  LICENSE "[NVIDIA](https://docs.nvidia.com/cuda/nvjpeg2000/license.html 'NVIDIA Software License Agreement')"
  SHA256_Darwin-arm64 f509fa5b26e97fa4c3a72d8a871a811182f958086dd93dff741c1de5accb27da
  SHA256_Linux-arm64 77b374aab05acc02fbaffa0c50476b30e9c2a0446922498786216d9ab58964df
  SHA256_Linux 3af2f9f73f79941b8a7ed12d1b158f1c2222b96b4857eb41bf0bda79e816d016
  SHA256_win64 86a810f9feb0495130c7b093a4e004b5764f57821f8e2f7739a973d5bb445e67
  )
set(xp_openh264 REPO github.com/externpro/openh264 TAG v1.4.0.1
  XPBLD "intro" BASE v1.4.0 DEPS yasm
  WEB "http://www.openh264.org/" UPSTREAM "github.com/cisco/openh264"
  DESC "a codec library which supports H.264 encoding and decoding"
  LICENSE "[BSD-2-Clause](http://www.openh264.org/faq.html 'BSD 2-Clause Simplified License')"
  SHA256_Darwin-arm64 893b7db45ce7c535ad1eab767e0987a879a425e99f81594feafba9150d029b46
  SHA256_Linux-arm64 99ade5a99d79da5ef7e9ae0ee89941c9fab03859ab847d1a6c7c83c85ae7de08
  SHA256_Linux 93e09307fef110a4cb51e21c7ddc986f65af14cec26c756da1b0514c8d32a563
  SHA256_win64 fdb01196f8ce0a16af3a78e1f42936d533a28a69e3b3fd12875217e6d776c012
  )
# TRICKY: nodexp, openssl versions coordinated
set(xp_openssl REPO github.com/externpro/openssl TAG v1.1.1l.3
  MANIFEST_SHA256 074219f553d0b095d73a5be1ae471cf48709cf062bfdcdaa7b3f8376f848fc1e
  )
set(xp_patch REPO github.com/externpro/patch TAG v2.7.6.4
  XPBLD "bin(msw), native(unix)" BASE v0
  WEB "https://savannah.gnu.org/projects/patch/" UPSTREAM "git.savannah.gnu.org/cgit/patch.git"
  DESC "takes a patch file containing a difference listing produced by the diff program and applies those differences to one or more original files, producing patched versions"
  LICENSE "[GPL-3.0](https://savannah.gnu.org/projects/patch/ 'GNU General Public License v3 or later')"
  SHA256_Darwin-arm64 ca3fb3bdfe73367de3713abfe2b8a61ebcb718e7d90a842676939cfb51d35773
  SHA256_Linux-arm64 896510084c48565a2069fff5e0362b8d469a8822aa551990597f333591776159
  SHA256_Linux 28a0698ec9881d6a8414409d36b59f000f6113559a76fe2e68dc88142c75a92b
  SHA256_win64 aab7af2d24e547946aa0d4468ca2bee2487970175ce10c595954fa782e3f7c32
  )
set(xp_protobuf REPO github.com/externpro/protobuf TAG v3.14.0.2
  MANIFEST_SHA256 28fca57139e1367e2823560211846d28f0f487e43fb0abfe60710c29a7f26854
  )
set(xp_rapidjson REPO github.com/externpro/rapidjson TAG v1.1.0-763.1
  XPBLD "patch" BASE v1.1.0-763
  WEB "http://Tencent.github.io/rapidjson/" UPSTREAM "github.com/Tencent/rapidjson"
  DESC "A fast JSON parser/generator for C++ with both SAX/DOM style API"
  LICENSE "[MIT](https://raw.githubusercontent.com/Tencent/rapidjson/master/license.txt 'MIT License')"
  SHA256_Darwin-arm64 360657595f6aaef3856578dbefcc3445673ff8827c5019d0b38b9eefc49ab4ce
  SHA256_Linux-arm64 37b38fc1ea0a2a098e4d2fd1c02617f605a230656eeda1c6d424bf8e13238950
  SHA256_Linux 6941459e00591d97b52cf3e50aae16c09c4de288f17ae1bf50ab8c4f0398bcf0
  SHA256_win64 b4029d033a9f41b54009e38824ec177d849138a2add3b02462480a2eff0dfbea
  )
set(xp_rapidxml REPO github.com/externpro/rapidxml TAG v1.13.1
  XPBLD "intro" BASE v1.13
  WEB "http://rapidxml.sourceforge.net/"
  DESC "fast XML parser"
  LICENSE "[BSL-1.0 or MIT](http://rapidxml.sourceforge.net/license.txt 'Boost Software License or MIT License')"
  SHA256_Darwin-arm64 4d00947669c5cf97561f180cf28b0c2b6f7fe91b95ef0fbc04545b55c49915a9
  SHA256_Linux-arm64 63e96a732bce5f38b11f5d5ccfcedb21849777f71c2051f98af54e8e37254cf5
  SHA256_Linux 127c9ca42df99ee61c7dce7263ec1d42ce0e154e26ad742c15e7f4a6c5dd04f7
  SHA256_win64 13ad304b798725f9084a8f39ab5b205f0afa5b7e0048a04ab9d1331798173118
  )
set(xp_shapelib REPO github.com/externpro/shapelib TAG v1.2.10.1
  XPBLD "intro" BASE 1.2.10
  WEB "http://shapelib.maptools.org/" UPSTREAM "github.com/OSGeo/shapelib"
  DESC "reading, writing, updating ESRI Shapefiles"
  LICENSE "[MIT or LGPL](http://shapelib.maptools.org/license.html 'MIT or LGPL License')"
  SHA256_Darwin-arm64 a9396c58ef8ae2375eb392d11e773eca78361a7f1c6c630ae1a17dd15bf1067c
  SHA256_Linux-arm64 b16e1ed28ef47b2ea477df7f204b9c28e1c40d6e6f6891c7d95aafbb63d36f83
  SHA256_Linux 4d5ae021737aaea49295377c5040ae247a91d922a19200252bb76bd3aa42e3d0
  SHA256_win64 e2b4970d2d040d35fb145c42dfca758da29bf4bbfee5d7ac5dfa48ab65e46cc3
  )
set(xp_spatialite-tools REPO github.com/externpro/spatialite-tools TAG v5.1.0.5
  XPBLD "auto" BASE 5.1.0a EXE_DEPS libspatialite
  WEB "https://www.gaia-gis.it/fossil/spatialite-tools/index"
  DESC "collection of open source Command Line Interface (CLI) tools supporting SpatiaLite"
  LICENSE "[GPL-3.0](https://www.gaia-gis.it/fossil/spatialite-tools/index 'GPL-3.0-or-later')"
  SHA256_Darwin-arm64 b6e093fc07be5d28485d68423599ef26dd3cbb550e050200af3d2a0e9bace314
  SHA256_Linux-arm64 46811c4d122e1ba8c00ea2e2d3cb1495ed763804fb4ea9b4499eb7338bb85fd7
  SHA256_Linux 14d9e25006371d2c64e866a0a021eaa721dad410bb8a5125a5019d09e1aee2a3
  SHA256_win64 1f3b86512e2f2a0b218a2db1eefddf121132304ac45f535b7d53940459b0214a
  )
set(xp_spdlog REPO github.com/externpro/spdlog TAG v1.15.3.3
  MANIFEST_SHA256 8c42801aad4d13383fcf76d600a1c9d1699ac856e416f16a91ee2fedfef81d92
  )
set(xp_sqlite3 REPO github.com/externpro/SQLite3 TAG v3.38.2.1
  XPBLD "patch" BASE 3.38.2
  WEB "https://www.sqlite.org/index.html 'SQLite website'" UPSTREAM "github.com/azadkuh/sqlite-amalgamation"
  DESC "C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine"
  LICENSE "[public domain](https://www.sqlite.org/copyright.html 'open-source, not open-contribution')"
  SHA256_Darwin-arm64 2845d6b59ddcb11e4c09e3d22a717b111953e80aa4df8a59227086a2d2bcb196
  SHA256_Linux-arm64 3959e9542480cf65b0ca265f131b934641824ed92fac38df3b8bc401f54b02ad
  SHA256_Linux 8cc51f5a86c75ed83956ede8e5aae6f076f213697009741765a5d402af3d4496
  SHA256_win64 0b59fc70300618ebc6a4eaf01fc63a41d43e37e003317cf1db68270674f9d171
  )
set(xp_wirehair REPO github.com/externpro/wirehair TAG v23.12.02.1
  XPBLD "patch" BASE v23.12.02
  WEB "https://github.com/catid/wirehair" UPSTREAM "github.com/catid/wirehair"
  DESC "fast and portable fountain codes in C"
  LICENSE "[BSD-3-Clause](https://github.com/catid/wirehair/blob/master/LICENSE 'BSD 3-Clause New or Revised License')"
  SHA256_Darwin-arm64 2950704bfd0b032b01a91a6c2c3397954b45047cdc25f33228105e186097631e
  SHA256_Linux-arm64 6d691b82afc5bba40ba778b78b07f7e69b7bf6b3c5be92552bc8b8b766715601
  SHA256_Linux bea56e35e2292b620532aab17058165e968c53c37bd7e6e660c7c4e1394d7f94
  SHA256_win64 c768565e46ac9aa99e04d19be7f84b6572dd389c741683769e4f4ffc01a75dd5
  )
set(xp_wxwidgets REPO github.com/externpro/wxWidgets TAG v3.1.0.5
  MANIFEST_SHA256 b8ccadd45baafe5af3342e03dff0331440d58b5c6d8df19559fad736ba736deb
  )
set(xp_wxcmake REPO github.com/externpro/wxcmake
  BASE wx0 BRANCH dev
  WEB "https://github.com/externpro/wxcmake 'wxcmake repo on github'"
  DESC "build wxWidgets via cmake [submodule of: _wxwidgets_]"
  LICENSE "[wxWindows](https://wxwidgets.org/about/licence/ 'same as wxWidgets license')"
  )
set(xp_wxinclude REPO github.com/externpro/wxInclude TAG v1.2.2
  MANIFEST_SHA256 3675dab0351a9ef6cdd8addb8010948b2fae8022496da56e1e181dcbaaaf5b08
  )
set(xp_wxtetris REPO github.com/smanders/wxTetris TAG v1.2.0
  XPBLD "intro" BASE v0 EXE_DEPS wxwidgets
  WEB "https://github.com/smanders/wxTetris"
  DESC "wxWidgets Tetris game"
  LICENSE "[MIT](https://github.com/smanders/wxTetris/blob/dev/LICENSE 'MIT License')"
  SHA256_Darwin-arm64 6aeace636c56f72746cef5acefe98ca859b14243f6178bc49fb4bbac2574af72
  SHA256_Linux-arm64 a2543dfcb6d3343724b3fed6f8cab70efd0631af30ede45443f91de6d5533008
  SHA256_Linux 984ed430f611b8bf03323902fa33a04ef8a28fc704fd5c32917bb26fe3912057
  SHA256_win64 b457f46b71d1787eb9e70fd5cf1ff16386937c53b021f5b70db79b2b61755ad7
  )
set(xp_wxx REPO github.com/externpro/wxx TAG v25.01
  XPBLD "intro" BASE v0 DEPS wxwidgets
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
set(xp_yasm REPO github.com/externpro/yasm TAG v1.3.0.2
  MANIFEST_SHA256 c2a6c8bed9feafbe6ac3972bad40fe36ec6bab51c9739f3b04f810f0e47016f4
  )
set(xp_zlib REPO github.com/externpro/zlib TAG v1.3.1.3
  MANIFEST_SHA256 895215459d64227b6f6fbd6c9580cb5cf8e637db3d7c5e750760ff66324222c2
  )
set(xp_zmqpp REPO github.com/externpro/zmqpp TAG v4.2.0-47.1
  XPBLD "patch" BASE 4.2.0-47 DEPS libzmq
  WEB "https://zeromq.github.io/zmqpp/" UPSTREAM "github.com/zeromq/zmqpp"
  DESC "high-level binding for libzmq"
  LICENSE "[MPL-2.0](https://github.com/zeromq/zmqpp/blob/develop/LICENSE 'Mozilla Public License 2.0')"
  SHA256_Darwin-arm64 b5ad4175ff759f6aec23214ce4749586ead28cd6f7be89333e26ad0aae0ed65f
  SHA256_Linux-arm64 848572b892b4e2a2cd3a24147ae20fd737437c9e6fa3e0d187250c32c58de896
  SHA256_Linux 9d8872646aa7f8e1d83d11864e098473dfc28e1c6f4ee17f466abe78c98813d5
  SHA256_win64 2303f474f05a28fe717deb889f1693284e2b8fea3ac8ceb48851bc75d48f42a0
  )
