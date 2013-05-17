#!/bin/sh -
# vim: softtabstop=4 shiftwidth=4 expandtab tw=80 fenc=utf-8

# Virtua Bootstrap for SmartOS
# To be used directly into a Zone

### Variables ###
BS_PKGIN_BASEURL="http://pkgsrc-eu-ams.joyent.com/packages/SmartOS/bootstrap"
BS_PKGIN_VER="bootstrap-2013Q1-x86_64.tar.gz"
PKGIN_VTA_REPO="http://tornado.virtua.ch/smartos_local/packages/All"
PKGIN_CNF_PATH="/opt/local/etc/pkgin/repositories.conf"
BS_SALT_BASEURL="https://raw.github.com/virtua-network/salt-bootstrap/develop"
BS_SALT_VER="bootstrap-salt.sh"
BS_SALT_ETC_DIR="/opt/local/etc/salt"
BS_SALT_TYPE="minion"

### Basic checks
if [ $(whoami) != "root" ] ; then
    echo "Requires root privileges to install."
    exit 1
fi

if [ $1 = "master" ]; then
    echo "[!!] Installing salt master"
    BS_SALT_TYPE="master"
fi

### Step 1. Prepare the environment ###
echo "[*] STEP 1 - Prepare the environment"
cd /
sed -I. "s/pkgsrc.joyent.com/pkgsrc-eu-ams.joyent.com/g" ${PKGIN_CNF_PATH}
pkgin -fy up
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
    env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- -M git develop
else
    curl -s -k -L ${BS_SALT_BASEURL}/${BS_SALT_VER} | \
    env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- git develop
fi

echo "[DONE]"
