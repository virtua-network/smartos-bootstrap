#!/bin/sh -
# vim: softtabstop=4 shiftwidth=4 expandtab tw=80 fenc=utf-8

# Virtua Bootstrap for SmartOS
# To be used directly on a CN after a fresh install

### Variables ###
PKGIN_BS_BASEURL="http://pkgsrc.joyent.com/packages/SmartOS/bootstrap"
PKGIN_BS_VER="bootstrap-2013Q1-x86_64.tar.gz"
PKGIN_VTA_REPO="http://tornado.virtua.ch/smartos_local/packages/All"
PKGIN_CNF_PATH="/opt/local/etc/pkgin/repositories.conf"
SALT_BS_BASEURL="https://raw.github.com/virtua-network/salt-bootstrap/develop"
SALT_BS_VER="bootstrap-salt.sh"

### Babyproof ###
if [[ -f /opt/local/bin/pkgin ]]; then
	echo "[ERROR] pkgin is already installed"
	exit 1
fi

### Step 1. Install pkgin in the CN ###
# From http://wiki.smartos.org/display/DOC/Installing+pkgin
echo "[*] STEP 1 - pkgin install on the CN"
cd /
curl -s -k ${PKGIN_BS_BASEURL}/${PKGIN_BS_VER} | \
gzcat | tar -xf -
pkg_admin rebuild
echo ${PKGIN_VTA_REPO} >> ${PKGIN_CNF_PATH} 
pkgin -fy up

### Step 2. Install Salt via bootstrap ###
echo "[*] STEP 2 - Salt Stack install"
curl -s -k -L ${SALT_BS_BASEURL}/${SALT_BS_VER} | \
sh -s -- -M -N git develop

echo "[DONE]"
