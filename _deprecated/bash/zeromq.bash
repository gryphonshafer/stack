#!/usr/bin/env bash

apt-get install \
    build-essential libtool pkg-config autoconf automake uuid-dev \
    libsodium13 libsodium-dev

mkdir /tmp/zeromq
cd /tmp/zeromq
$wget http://download.zeromq.org

latest_version=$( cat index.html | grep zeromq | grep tar | \
    sed -e 's/^.*<a href="//' | sed -e 's/".*//' | \
    grep -v rc | grep -v alpha | grep -v beta | \
    sort -r | head -1 )

wget http://download.zeromq.org/$latest_version

tar xfpz $latest_version

this_version=$( echo $latest_version | sed -e 's/\.tar\.gz//' )
cd $this_version

./configure
make
make install
ldconfig

cd /tmp
rm -rf zeromq
