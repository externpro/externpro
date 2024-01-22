#/bin/sh
# buildpro custom network performance tuning
sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.core.rmem_default
sysctl net.core.wmem_default
sysctl net.ipv4.tcp_rmem
sysctl net.ipv4.tcp_wmem
sysctl net.ipv4.tcp_mem
sysctl net.ipv4.udp_rmem_min
sysctl net.ipv4.udp_wmem_min
sysctl net.ipv4.udp_mem

