message(STATUS "pkg_url: ${pkg_url}")
message(STATUS "pkg_md5: ${pkg_md5}")
message(STATUS "pkg_dir: ${pkg_dir}")
file(DOWNLOAD ${pkg_url} ${pkg_dir} INACTIVITY_TIMEOUT 45 EXPECTED_MD5 ${pkg_md5} SHOW_PROGRESS)

