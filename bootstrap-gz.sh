#!/bin/sh -
# vim: softtabstop=4 shiftwidth=4 expandtab tw=80 fenc=utf-8

# Virtua Bootstrap for SmartOS
# To be used directly on a CN after a fresh install

### Variables ###
BS_PKGIN_BASEURL="http://pkgsrc-eu-ams.joyent.com/packages/SmartOS/bootstrap"
BS_PKGIN_VER="bootstrap-2013Q2-x86_64.tar.gz"
PKGIN_VTA_REPO="http://tornado.virtua.ch/smartos_local/packages/All"
PKGIN_CNF_PATH="/opt/local/etc/pkgin/repositories.conf"
BS_VERSION="develop"
BS_SALT_BASEURL="https://raw.github.com/virtua-network/salt-bootstrap"
BS_SALT_VER="${BS_VERSION}/bootstrap-salt.sh"
BS_SALT_ETC_DIR="/opt/local/etc/salt"
NODE_NAME="newnode"

### Basic checks ###
if [ -f /opt/local/bin/pkgin ]; then
	echo "[ERROR] pkgin is already installed"
	exit 1
fi

if [ "$#" -gt 2 ]; then
    echo "[ERROR] sorry this script takes maximum 2 arguments"
    exit 1
fi

case "$#" in
    1 )     NODE_NAME=$1                ;;
    2 )     NODE_NAME=$1;BS_VERSION=$2  ;;
esac

echo "[INFO] The Node Name will be set to ${NODE_NAME}"
echo "[INFO] Version : ${BS_VERSION}"

### Step 1. Install pkgin in the CN ###
# From http://wiki.smartos.org/display/DOC/Installing+pkgin
echo "[*] STEP 1 - pkgin install on the CN"
cd /
curl -s -k ${BS_PKGIN_BASEURL}/${BS_PKGIN_VER} | \
gzcat | tar -xf -
pkg_admin rebuild
sed -i.orig "s/pkgsrc.joyent.com/pkgsrc-eu-ams.joyent.com/g" ${PKGIN_CNF_PATH}
pkgin -fy up

### Step 2. Install Salt via bootstrap ###
echo "[*] STEP 2 - Salt Stack install"
curl -s -k -L ${BS_SALT_BASEURL}/${BS_SALT_VER} | \
env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- stable 

### Step 3. Naming the Node ###
echo "[*] STEP 3 - Naming Node"
sed -i.orig "s/\#id\:/id\:\ ${NODE_NAME}/" ${BS_SALT_ETC_DIR}/minion
sed -i.orig "s/\#startup_states\:\ \'\'/startup_states\:\ \'highstate\'/" \
    ${BS_SALT_ETC_DIR}/minion
svcadm restart salt-minion
echo "[DONE]"
