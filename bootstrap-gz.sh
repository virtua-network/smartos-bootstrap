#!/bin/sh -
# vim: softtabstop=4 shiftwidth=4 expandtab tw=80 fenc=utf-8

# Virtua Bootstrap for SmartOS
# To be used directly on a CN after a fresh install

### Variables ###
BS_PKGIN_BASEURL="http://pkgsrc-eu-ams.joyent.com/packages/SmartOS/bootstrap"
BS_PKGIN_VER="bootstrap-2013Q1-x86_64.tar.gz"
PKGIN_VTA_REPO="http://tornado.virtua.ch/smartos_local/packages/All"
PKGIN_CNF_PATH="/opt/local/etc/pkgin/repositories.conf"
BS_SALT_BASEURL="https://raw.github.com/virtua-network/salt-bootstrap"
BS_SALT_VER="2013Q1/bootstrap-salt.sh"
BS_SALT_ETC_DIR="/opt/local/etc/salt"
NODE_NAME="newnode"

### Basic checks ###
if [ -f /opt/local/bin/pkgin ]; then
	echo "[ERROR] pkgin is already installed"
	exit 1
fi

if [ $1 ] ; then
    echo "The Node Name will be set to $1."
    NODE_NAME=$1
fi

### Step 1. Install pkgin in the CN ###
# From http://wiki.smartos.org/display/DOC/Installing+pkgin
echo "[*] STEP 1 - pkgin install on the CN"
cd /
curl -s -k ${BS_PKGIN_BASEURL}/${BS_PKGIN_VER} | \
gzcat | tar -xf -
pkg_admin rebuild
sed -i.orig "s/pkgsrc.joyent.com/pkgsrc-eu-ams.joyent.com/g" ${PKGIN_CNF_PATH}
pkgin -fy up

### Step 2. Install packages not -yet- distributed by Joyent
echo "[*] STEP 2 - install packages that are not *yet* distributed by Joyent"
pkgin -y in libuuid python27 py27-setuptools
pkg_add ${PKGIN_VTA_REPO}/msgpack-0.5.7.tgz
pkg_add ${PKGIN_VTA_REPO}/zeromq-3.2.3.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-zmq-2.2.0.1.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-m2crypto-0.21.1nb2.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-jinja2-2.6.tgz
pkg_add ${PKGIN_VTA_REPO}/py27-msgpack-0.1.13.tgz

### Step 3. Install Salt via bootstrap ###
echo "[*] STEP 3 - Salt Stack install"
curl -s -k -L ${BS_SALT_BASEURL}/${BS_SALT_VER} | \
env BS_SALT_ETC_DIR=${BS_SALT_ETC_DIR} sh -s -- git 2013Q1 

### Step 4. Naming the Node ###
echo "[*] STEP 4 - Naming Node"
sed -i.orig "s/\#id\:/id\:\ ${NODE_NAME}/" ${BS_SALT_ETC_DIR}/minion
sed -i.orig "s/\#startup_states\:\ \'\'/startup_states\:\ \'highstate\'/" \
    ${BS_SALT_ETC_DIR}/minion
svcadm restart salt-minion
echo "[DONE]"
