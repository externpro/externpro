# buildpro/.devcontainer

## Table of Contents
- [notes](#notes)
  - [networks](#networks)
  - [X11 forwarding](#X11-forwarding)
  - [network performance tuning](#network-performance-tuning)
  - [database](#database)

## notes

### networks
* `compose.vantage.yml` creates a user-defined bridge network with suffix `bpnet`
  ```
  $ docker network ls
  NETWORK ID     NAME             DRIVER    SCOPE
  643087dbdb12   bridge           bridge    local
  3827d410c2f9   buildpro_bpnet   bridge    local
  49e8e437e86b   host             host      local
  9c91da65ca0b   none             null      local
  ```
* from https://docs.docker.com/network/
  > User-defined bridge networks are best when you need multiple containers to
    communicate on the same Docker host
* other benefits and differences bewteen user-defined bridges and the default bridge
  are detailed in the docker docs
  https://docs.docker.com/network/bridge/
  * user-defined bridges provide automatic DNS resolution between containers
  * user-defined bridges provide better isolation
  * containers can be attached and detached from user-defined networks on the fly
  * each user-defined network creates a configurable bridge
    * the `bpnet` network includes `driver_opts`
      `com.docker.network.driver.mtu: "9000"`
      to "turn on" [jumbo frames](https://en.wikipedia.org/wiki/Jumbo_frame)
    * https://docs.docker.com/engine/reference/commandline/network_create/#bridge-driver-options
    * this can be verified inside the container
      ```
      $ ip link show | grep mtu
      1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
      44: eth0@if45: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP mode DEFAULT group default
      ```

#### X11 forwarding
* if you're running `./docker-compose.sh` on a remote system you've connected to via `ssh -X` or `ssh -Y`
  the [denv.sh](denv.sh) script should automatically detect this case and will do additional
  configuration and populate environment variables so that X display from the running container will (hopefully)
  work as expected
* NOTE: the `-bld` images include the `xeyes` package, which can be run (`$ xeyes &`) from the
  container to verify X11 forwarding is working as expected
* TIP: if you get a "can't open display" error trying to run X applications, you may need
  to change the `X11UseLocalhost` option in `/etc/ssh/sshd_config` to `no` (and restart sshd)

#### network performance tuning
* with `/etc/sysctl.conf` you can configure various linux kernel networking settings
* some of these settings are required to be modified for Autotest
  (in the runtime container) to succeed
* some `--sysctl` settings can be applied to a container, but I found that none of the required changes
  could be done this way (or at least in my attempts with Docker version 18.09.7)
  https://docs.docker.com/engine/reference/commandline/run/#configure-namespaced-kernel-parameters-sysctls-at-runtime
* these settings need to be applied to the host, then the docker container
  (which shares the host kernel) will have the required settings
* https://unix.stackexchange.com/questions/404387/how-to-sysctl-net-related-config-in-docker-container/455193
* the `/etc/sysctl.d/README` explains the directory's relation to `/etc/sysctl.conf` and mentions
  > After making any changes, please run "service procps start"
  * I believe they meant `restart` instead of `start`
* the script [check-bpnet-perform.sh](check-bpnet-perform.sh) will help
  to check the values before applying the changes in
  [90-bpnet-perform.conf](90-bpnet-perform.conf) -- in case you'd like to
  ever go back to the original, default values
  ```
  $ ./check-bpnet-perform.sh
  net.core.rmem_max = 212992
  net.core.wmem_max = 212992
  net.core.rmem_default = 212992
  net.core.wmem_default = 212992
  net.ipv4.tcp_rmem = 4096	87380	6291456
  net.ipv4.tcp_wmem = 4096	16384	4194304
  net.ipv4.tcp_mem = 383520	511360	767040
  net.ipv4.udp_rmem_min = 4096
  net.ipv4.udp_wmem_min = 4096
  net.ipv4.udp_mem = 767040	1022720	1534080

  $ sudo cp 90-bpnet-perform.conf /etc/sysctl.d/
  $ sudo service procps restart

  $ ./check-bpnet-perform.sh
  net.core.rmem_max = 8388608
  net.core.wmem_max = 8388608
  net.core.rmem_default = 8388608
  net.core.wmem_default = 8388608
  net.ipv4.tcp_rmem = 94096	987380	8388608
  net.ipv4.tcp_wmem = 94096	987380	8388608
  net.ipv4.tcp_mem = 8388608	8388608	8388608
  net.ipv4.udp_rmem_min = 8388608
  net.ipv4.udp_wmem_min = 8388608
  net.ipv4.udp_mem = 8388608	8388608	8388608
  ```
* the bash function `runreq` in [funcs.sh](funcs.sh) attempts to automate this

#### database
* https://dev.mysql.com/doc/refman/8.0/en/docker-mysql-getting-started.html
* https://severalnines.com/database-blog/mysql-docker-containers-understanding-basics
* verify start-up configuration is as-expected (changed from defaults)
  ```
  $ docker exec -it mysqlpro mysql -uvantage -p
  mysql> SELECT @@innodb_buffer_pool_size;
  mysql> SELECT @@innodb_flush_log_at_trx_commit;
  mysql> SELECT @@sql_mode;
  mysql> quit;
  ```
* some useful mysql commands to get configuration correct
  ```
  $ docker exec -it mysqlpro bash
  $ mysqld --verbose --help (to see default values)
  $ mysqladmin -uroot -p variables
  ```
* troubleshooting the runtime/database container connection
  ```
  $ ./docker-compose.sh -r
  $ cat ~/.odbc.ini
  $ cat /etc/odbcinst.ini
  $ isql mock_midb_dsn
  ```
