set(xp_apr REPO github.com/externpro/apr XP_MODULE)
set(xp_bzip2 REPO github.com/externpro/bzip2 XP_MODULE)
set(xp_cares REPO github.com/externpro/c-ares XP_MODULE)
set(xp_clangformat XP_MODULE)
set(xp_criticalio REPO isrhub.usurf.usu.edu/internpro/CriticalIO TAG v2.0.02.7
  SHA256_Linux a7f5c669341df7f7e24b9405c448531f8377c366bb59676f301f409206beec46
  SHA256_win64 9d4462f14d5baaf12f34adc2f2c5317a59b98069be6845c2f02dd11417f8066f
  )
set(xp_eigen REPO github.com/externpro/eigen XP_MODULE)
set(xp_expat REPO github.com/externpro/libexpat XP_MODULE)
set(xp_fftw REPO isrhub.usurf.usu.edu/internpro/xpfftw TAG v3.3.8
  SHA256_Linux 5a11f07c1506bfba3d7ac48fa09ef52f527b719e17624b6bdff95d9df99e78b2
  SHA256_win64 fa55d30988499cee66c0af29cf1bc272fee2b45b130b5b529fa397986925af73
  )
set(xp_flatbuffers REPO github.com/externpro/flatbuffers XP_MODULE)
set(xp_geotrans REPO github.com/externpro/geotranz XP_MODULE)
set(xp_glew REPO github.com/externpro/glew XP_MODULE)
set(xp_gsoap REPO isrhub.usurf.usu.edu/internpro/gsoap TAG v2.8.97.1
  SHA256_Linux 67022a5a489989ed5efc4a640d5f41e6aabad7bf1e23d7745a65b98ec9727ca3
  SHA256_win64 3edf169315ea781dbe8234851a1306a23824f9fe3cf810c05c010f4d76513502
  )
set(xp_jasper REPO github.com/externpro/jasper XP_MODULE)
set(xp_jpegxp REPO github.com/externpro/jpegxp XP_MODULE)
set(xp_jxrlib REPO github.com/externpro/jxrlib XP_MODULE)
set(xp_kakadu REPO isrhub.usurf.usu.edu/internpro/kakadu TAG v6.1.1.0
  SHA256_Linux 491323e88514eb27b46e2cebcbfbb637a8ce58c2242fb434eb5951a429f5d0dd
  SHA256_win64 2a3a791616c2fe745279d08d209fbabd63bd5eb661127160671f0ccdd75124a8
  )
set(xp_lua REPO github.com/externpro/lua XP_MODULE)
set(xp_opensslasm REPO github.com/externpro/opensslasm)
set(xp_nasm)
set(xp_patch REPO github.com/externpro/xppatch TAG v2.7
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
set(xp_dde_lib REPO isrhub.usurf.usu.edu/DDE/dde_lib DEPS boost protobuf wirehair XP_MODULE)
set(xp_fecpp REPO github.com/externpro/fecpp DEPS boost XP_MODULE)
set(xp_ffmpeg REPO github.com/externpro/FFmpeg openh264 yasm XP_MODULE)
set(xp_libssh2 REPO github.com/externpro/libssh2 DEPS openssl zlib XP_MODULE)
set(xp_libstrophe REPO github.com/externpro/libstrophe DEPS expat openssl XP_MODULE)
set(xp_node-addon-api REPO github.com/externpro/node-addon-api DEPS node XP_MODULE)
set(xp_palam REPO isrhub.usurf.usu.edu/palam/palam TAG v1.10.10.5
  DEPS boost eigen fftw geotrans jasper jpegxp jxrlib kakadu openssl protobuf rapidjson rapidxml wxwidgets wxx
  SHA256_Linux 531cb178673e5870911d26f467643a2787732c430312e14331da8c3044c1e78c
  )
set(xp_sdl_ggdp REPO isrhub.usurf.usu.edu/internpro/NG_GDP DEPS boost XP_MODULE)
set(xp_wxinclude REPO github.com/externpro/wxInclude DEPS boost XP_MODULE)
set(xp_zmqpp REPO github.com/externpro/zmqpp DEPS libzmq XP_MODULE)
### depend on previous group
set(xp_curl REPO github.com/externpro/curl DEPS cares libssh2 XP_MODULE)
set(xp_libgit2 REPO github.com/externpro/libgit2 DEPS libssh2 XP_MODULE)
set(xp_sdvideo REPO isrhub.usurf.usu.edu/internpro/Sdvideo DEPS boost ffmpeg XP_MODULE)
