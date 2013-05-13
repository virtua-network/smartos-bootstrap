#!/bin/sh -
# vim: softtabstop=4 shiftwidth=4 expandtab tw=80 fenc=utf-8

# Virtua Bootstrap for SmartOS
# To be used directly on a CN after a fresh install

### Variables ###
BS_PKGIN_BASEURL="http://pkgsrc.joyent.com/packages/SmartOS/bootstrap"
BS_PKGIN_VER="bootstrap-2013Q1-x86_64.tar.gz"
PKGIN_VTA_REPO="http://tornado.virtua.ch/smartos_local/packages/All"
PKGIN_CNF_PATH="/opt/local/etc/pkgin/repositories.conf"
BS_SALT_BASEURL="https://raw.github.com/virtua-network/salt-bootstrap/develop"
BS_SALT_VER="bootstrap-salt.sh"
BS_SALT_ETC_DIR="/opt/local/etc/salt"

### Babyproof ###
if [[ -f /opt/local/bin/pkgin ]]; then
	echo "[ERROR] pkgin is already installed"
	exit 1
fi

### Step 1. Install pkgin in the CN ###
# From http://wiki.smartos.org/display/DOC/Installing+pkgin
echo "[*] STEP 1 - pkgin install on the CN"
cd /
curl -s -k ${BS_PKGIN_BASEURL}/${BS_PKGIN_VER} | \
gzcat | tar -xf -
pkg_admin rebuild
echo ${PKGIN_VTA_REPO} >> ${PKGIN_CNF_PATH} 
pkgin -fy up

### Step 2. Install Salt via bootstrap ###
echo "[*] STEP 2 - Salt Stack install"
curl -s -k -L ${BS_SALT_BASEURL}/${BS_SALT_VER} | \
env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- git develop

echo "[DONE]"
