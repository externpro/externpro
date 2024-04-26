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
set(xp_fftw REPO isrhub.usurf.usu.edu/internpro/fftw TAG v3.3.8.1
  SHA256_Linux 141b17828250cb9ce1bf9fcef0e34b398b0ca78682531879156022a26bdc5185
  SHA256_win64 af6fa110206183a89417aa0826bfd2d50af119a4ae0728ea4bfa78712bd466f7
  )
set(xp_flatbuffers REPO github.com/externpro/flatbuffers XP_MODULE)
set(xp_geotrans REPO github.com/externpro/geotranz XP_MODULE)
set(xp_glew REPO github.com/externpro/glew XP_MODULE)
set(xp_gsoap REPO isrhub.usurf.usu.edu/internpro/gsoap TAG v2.8.97.2
  SHA256_Linux 6a1e6143e19626aab6df1c24e0df3b43390f69afcc2af6673f56329887e3c038
  SHA256_win64 a2d8ed8759892e341b4dd19be5968cc672dbf658aa5e6c4316c0940c464d89bd
  )
set(xp_jasper REPO github.com/externpro/jasper XP_MODULE)
set(xp_jpegxp REPO github.com/externpro/jpegxp XP_MODULE)
set(xp_jxrlib REPO github.com/externpro/jxrlib XP_MODULE)
set(xp_kakadu REPO isrhub.usurf.usu.edu/internpro/kakadu TAG v6.1.1.2
  SHA256_Linux db3eb67ff724c8e41342905d0d51e5e24366133e39c20910af07358721977233
  SHA256_win64 759cdbb9dfcfb2ed51b488d0338fc9f5b2e380e2dfc975173e70f100bd73eb8d
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
set(xp_dde_lib REPO isrhub.usurf.usu.edu/DDE/dde_lib TAG v0.0.0.8 DEPS boost protobuf wirehair
  SHA256_Linux 20dfd9dc7726aaa8e3667df764ba0a77ebfb09ba0be42227e20002eada7f69a3
  SHA256_win64 9e571c600a362e18141c9c50ab6bfc7add7405ec553003caf06a1923286a2772
  )
set(xp_fecpp REPO github.com/externpro/fecpp DEPS boost XP_MODULE)
set(xp_ffmpeg REPO github.com/externpro/FFmpeg openh264 yasm XP_MODULE)
set(xp_libssh2 REPO github.com/externpro/libssh2 DEPS openssl zlib XP_MODULE)
set(xp_libstrophe REPO github.com/externpro/libstrophe DEPS expat openssl XP_MODULE)
set(xp_node-addon-api REPO github.com/externpro/node-addon-api DEPS node XP_MODULE)
set(xp_palam REPO isrhub.usurf.usu.edu/palam/palam TAG v1.11.0.0
  DEPS boost eigen fftw geotrans jasper jpegxp jxrlib kakadu openssl protobuf rapidjson rapidxml wxwidgets wxx
  SHA256_Linux 8561de9d2bbf1b04badf461639028a1b164cbf4ef5083c9485dc206e09634b8c
  SHA256_win64 b9d3e691aa23358076604a141b13402f45f994cb1ed2dfe3263244eb4d35313f
  )
set(xp_ng_gdp REPO isrhub.usurf.usu.edu/internpro/NG_GDP TAG v24.01 DEPS boost
  SHA256_Linux a5ca9eede75a00b436499d714b7fef703414b30d00463baa8420c30cf4606dee
  SHA256_win64 df337bb8de204ce8b9f1ab263c31e01f9213e17e27c222e8b0043292d5d78d36
  )
set(xp_wxinclude REPO github.com/externpro/wxInclude EXE_DEPS boost XP_MODULE)
set(xp_zmqpp REPO github.com/externpro/zmqpp DEPS libzmq XP_MODULE)
### depend on previous group
set(xp_curl REPO github.com/externpro/curl DEPS cares libssh2 XP_MODULE)
set(xp_libgit2 REPO github.com/externpro/libgit2 DEPS libssh2 XP_MODULE)
set(xp_pluginsdk REPO isrhub.usurf.usu.edu/Vantage/PluginSdk TAG v3.5.0.2 EXE_DEPS palam
  SHA256_Linux 30f268d16df0ebb28d168b776eccf4c3cba6de0c82b265382fd9fc921442bd1f
  SHA256_win64 ea919c4a2615f127a6264b81e31010f8a314feefd5c5227bd740ee250fe35fbe
  )
set(xp_sdvideo REPO isrhub.usurf.usu.edu/internpro/Sdvideo TAG v24.01 DEPS boost ffmpeg
  SHA256_Linux 7976e19d0aa5277f94094f95dee629e67fecd22e5f377619385a7504d2a89d73
  SHA256_win64 db414f7c15dfeac971e0dc13bfbc9fdd03682294cb77a6de18a4be9c457ad2e0
  )
