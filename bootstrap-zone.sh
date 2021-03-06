#!/bin/sh -
# vim: softtabstop=4 shiftwidth=4 expandtab tw=80 fenc=utf-8

# Virtua Bootstrap for SmartOS
# To be used directly into a Zone

### Variables ###
PKGIN_VTA_REPO="http://tornado.virtua.ch/smartos_local/packages/All"
PKGIN_CNF_PATH="/opt/local/etc/pkgin/repositories.conf"
BS_VERSION="2013Q1"
BS_SALT_BASEURL="https://raw.github.com/virtua-network/salt-bootstrap"
BS_SALT_VER="${BS_VERSION}/bootstrap-salt.sh"
BS_SALT_ETC_DIR="/opt/local/etc/salt"
BS_SALT_TYPE="minion"
NODE_NAME="newnode"

### Basic checks
if [ $(whoami) != "root" ]; then
    echo "Requires root privileges to install."
    exit 1
fi

if [ "$#" -gt 3 ]; then
    echo "[ERROR] sorry this script takes maximum 3 arguments"
    exit 1
fi

case "$#" in
    1 ) [ "$1" = "master" ] && BS_SALT_TYPE=$1                              ;;
    2 ) [ "$1" = "master" ] && BS_SALT_TYPE=$1;NODE_NAME=$2                 ;;
    3 ) [ "$1" = "master" ] && BS_SALT_TYPE=$1;NODE_NAME=$2;BS_VERSION=$3   ;;
esac

echo "[INFO] Installing salt-${BS_SALT_TYPE}"
echo "[INFO] The Node Name will be set to ${NODE_NAME}"
echo "[INFO] Version : ${BS_VERSION}"

### Step 1. Prepare the environment ###
echo "[*] STEP 1 - Prepare the environment"
cd /
pkgin -y in libuuid python27 py27-setuptools
pkg_add ${PKGIN_VTA_REPO}/msgpack-0.5.7.tgz
pkg_add ${PKGIN_VTA_REPO}/zeromq-3.2.3.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-zmq-2.2.0.1.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-m2crypto-0.21.1nb2.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-jinja2-2.6.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-msgpack-0.1.13.tgz

### Step 2. Install Salt via bootstrap ###
echo "[*] STEP 2 - Salt Stack install"
if [ ${BS_SALT_TYPE} = "master" ]; then
    curl -s -k -L ${BS_SALT_BASEURL}/${BS_SALT_VER} | \
    env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- -M git ${BS_VERSION}
else
    curl -s -k -L ${BS_SALT_BASEURL}/${BS_SALT_VER} | \
    env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- git ${BS_VERSION}
fi

### Step 3. Naming the Node ###
echo "[*] STEP 3 - Naming Node"
sed -i.orig "s/\#id\:/id\:\ ${NODE_NAME}/" ${BS_SALT_ETC_DIR}/minion
sed -i.orig "s/\#startup_states\:\ \'\'/startup_states\:\ \'highstate\'/" \
    ${BS_SALT_ETC_DIR}/minion
svcadm restart salt-minion
echo "[DONE]"
