#!/bin/bash
set -e

HOSTNAME="${HOSTNAME:-huliboot}"
# 默认 DNS: 阿里云公共 DNS (主 223.5.5.5 / 备 223.6.6.6)
NAMESERVER="${NAMESERVER:-223.5.5.5 223.6.6.6}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🌐 配置网络和主机名"

rm -f rootdir/etc/resolv.conf
touch rootdir/etc/resolv.conf

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 主机名: ${HOSTNAME}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ DNS: ${NAMESERVER}"

for ns in ${NAMESERVER}; do
    echo "nameserver ${ns}" >> rootdir/etc/resolv.conf
done
echo "${HOSTNAME}" > rootdir/etc/hostname
echo "127.0.0.1 localhost
127.0.1.1 ${HOSTNAME}" > rootdir/etc/hosts

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 网络配置完成"