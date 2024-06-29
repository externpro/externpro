set(xp_apr REPO github.com/externpro/apr XP_MODULE)
set(xp_bzip2 REPO github.com/externpro/bzip2 XP_MODULE)
set(xp_cares REPO github.com/externpro/c-ares XP_MODULE)
set(xp_clangformat XP_MODULE)
set(xp_criticalio REPO isrhub.usurf.usu.edu/internpro/CriticalIO TAG v2.0.02.8
  SHA256_Linux abbcbeccfede2ab2538e85aec06f59b4d288a549f3969c5e39b666b47df06bc8
  SHA256_win64 0cf13caaaf04d55bd32ff5578eba6265579afcd287162b978a8683945eebc248
  )
set(xp_eigen REPO github.com/externpro/eigen XP_MODULE)
set(xp_expat REPO github.com/externpro/libexpat XP_MODULE)
set(xp_fftw REPO isrhub.usurf.usu.edu/internpro/fftw TAG v3.3.8.2
  SHA256_Linux 9c296f908984fda88d2bb198048ccf56d32f046cff6e60b18c675b6280552deb
  SHA256_win64 e8d034171b2453d4c0981c268d7a39c6b3456584c94e91790a5d1ee32432a3c8
  )
set(xp_flatbuffers REPO github.com/externpro/flatbuffers XP_MODULE)
set(xp_geotrans REPO github.com/externpro/geotranz XP_MODULE)
set(xp_glew REPO github.com/externpro/glew XP_MODULE)
set(xp_gsoap REPO isrhub.usurf.usu.edu/internpro/gsoap TAG v2.8.97.3
  SHA256_Linux d4447bf40ea1952d013c23d328af9cd3d8244ff126b7856c1b1c96655a6a7b2f
  SHA256_win64 0faafb04dbb116bd66a5c958f10df83efccc8e5368f31fa55aed3edb139ce14e
  )
set(xp_jasper REPO github.com/externpro/jasper XP_MODULE)
set(xp_jpegxp REPO github.com/externpro/jpegxp XP_MODULE)
set(xp_jxrlib REPO github.com/externpro/jxrlib XP_MODULE)
set(xp_kakadu REPO isrhub.usurf.usu.edu/internpro/kakadu TAG v6.1.1.4
  SHA256_Linux cf26edb0b133ce6a85245ebf59e89bc0263ce1acc93d7f3fc555f241e7e9c9e7
  SHA256_win64 311c4b20e95ffdceb0e158236e27d075ce4db952b1001fc0fe530353d54e76da
  )
set(xp_lua REPO github.com/externpro/lua XP_MODULE)
set(xp_opensslasm REPO github.com/externpro/opensslasm)
set(xp_nasm REPO github.com/externpro/nasm TAG v2.14.02
  SHA256_Linux 31fb78aa856e58716b5cf36927a24824e1fc931a375b02b9c24245a5ed3e3347
  SHA256_win64 ddf6097be3ecf6e63cdcc56dbc6f063f44cf4ba04e8df73c2c6c3798c3f98428
  )
set(xp_patch REPO github.com/externpro/patch TAG v2.7
  SHA256_Linux b72b6b36acd65f6dc66e988a2edbbf483377c69d9fdf1f2537f3ec474f345196
  SHA256_win64 0e7852bd14863f7e1f5ac29a29dba83d75d92963e2f4c4bb7628397a2bf96e63
  )
set(xp_rapidjson REPO github.com/externpro/rapidjson XP_MODULE)
set(xp_rapidxml REPO github.com/externpro/rapidxml XP_MODULE)
set(xp_shapelib REPO github.com/externpro/shapelib XP_MODULE)
set(xp_sodium REPO github.com/externpro/libsodium XP_MODULE)
set(xp_sqlite REPO github.com/externpro/sqlite-amalgamation XP_MODULE)
set(xp_wirehair REPO github.com/externpro/wirehair XP_MODULE)
set(xp_wxwidgets REPO github.com/externpro/wxWidgets XP_MODULE)
set(xp_yasm REPO github.com/externpro/yasm)
set(xp_zlib REPO github.com/externpro/zlib XP_MODULE)
### depend on previous group
set(xp_boost DEPS bzip2 zlib XP_MODULE)
set(xp_ceres REPO github.com/externpro/ceres-solver DEPS eigen XP_MODULE)
set(xp_geotiff REPO github.com/externpro/libgeotiff DEPS wxwidgets XP_MODULE)
set(xp_libzmq REPO github.com/externpro/libzmq DEPS sodium XP_MODULE)
set(xp_node REPO github.com/externpro/node DEPS nasm XP_MODULE)
set(xp_openh264 REPO github.com/externpro/openh264 DEPS yasm XP_MODULE)
set(xp_openssl REPO github.com/externpro/openssl DEPS nasm opensslasm XP_MODULE)
set(xp_protobuf REPO github.com/externpro/protobuf DEPS zlib XP_MODULE)
set(xp_wxx REPO github.com/externpro/wxx DEPS wxwidgets XP_MODULE)
### depend on previous group
set(xp_activemqcpp REPO github.com/externpro/activemq-cpp DEPS apr openssl XP_MODULE)
set(xp_azmq REPO github.com/externpro/azmq DEPS boost libzmq XP_MODULE)
set(xp_cppzmq REPO github.com/externpro/cppzmq DEPS libzmq XP_MODULE)
set(xp_dde_lib REPO isrhub.usurf.usu.edu/DDE/dde_lib TAG v0.0.0.9 DEPS boost protobuf wirehair
  SHA256_Linux 89cd585be2403a904e8241d9b1893774e275ab020275b4e1703df819ac734cb6
  SHA256_win64 dc1133d19be5f36fbc53a799a9a75f662259b67d5ec9d2f1b304fb34b4c7b350
  )
set(xp_fecpp REPO github.com/externpro/fecpp DEPS boost XP_MODULE)
set(xp_ffmpeg REPO github.com/externpro/FFmpeg openh264 yasm XP_MODULE)
set(xp_libssh2 REPO github.com/externpro/libssh2 DEPS openssl zlib XP_MODULE)
set(xp_libstrophe REPO github.com/externpro/libstrophe DEPS expat openssl XP_MODULE)
set(xp_node-addon-api REPO github.com/externpro/node-addon-api DEPS node XP_MODULE)
set(xp_palam REPO isrhub.usurf.usu.edu/palam/palam TAG v1.11.2.0
  DEPS boost eigen fftw geotrans jasper jpegxp jxrlib kakadu openssl protobuf rapidjson rapidxml wxwidgets wxx
  SHA256_Linux 0a2c2a8058d6fb62913d886bd08bbb3b2bc1b3c9d54dc284260c366abad27a4d
  SHA256_win64 8761d810741d07b48188f3ba5adf0c9666a493d5b400d89b99be82fab78b507b
  )
set(xp_ng_gdp REPO isrhub.usurf.usu.edu/internpro/NG_GDP TAG v24.02 DEPS boost
  SHA256_Linux f6356221c2111223327aa70101d1d93d7fc6a11be835a3d1ec04da9353975c97
  SHA256_win64 0e0f3ba69faa7c902bf1a6dea13bde161b5622cfa6eb430909a67aa1f156148f
  )
set(xp_wxinclude REPO github.com/externpro/wxInclude EXE_DEPS boost XP_MODULE)
set(xp_zmqpp REPO github.com/externpro/zmqpp DEPS libzmq XP_MODULE)
### depend on previous group
set(xp_curl REPO github.com/externpro/curl DEPS cares libssh2 XP_MODULE)
set(xp_libgit2 REPO github.com/externpro/libgit2 DEPS libssh2 XP_MODULE)
set(xp_pluginsdk REPO isrhub.usurf.usu.edu/Vantage/PluginSdk TAG v3.5.0.3 EXE_DEPS palam
  SHA256_Linux e1f9bc4724027c9f1fcf09e93edf2dcc5ee865d4ff5c7936ce051e6a29005880
  SHA256_win64 8436a774edfeb3dc7757e65fbe44c27a7db84b0f7725d398e4ce4faabc6f5751
  )
set(xp_sdvideo REPO isrhub.usurf.usu.edu/internpro/Sdvideo TAG v24.02 DEPS boost ffmpeg
  SHA256_Linux 25ba1530f23c483ea1817266bad303665cdd43a265283d8f5c1cccda2068cf7f
  SHA256_win64 860006e31454e0074c9ef365210d92c199e9cdc1741fe1835ecc569344e2b0bb
  )
