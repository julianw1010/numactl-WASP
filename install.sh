#!/usr/bin/env bash
set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    ID_LIKE_ALL="$ID $ID_LIKE"
else
    echo "Cannot detect OS"; exit 1
fi

case "$ID_LIKE_ALL" in
    *debian*|*ubuntu*)
        sudo apt-get update
        sudo apt-get install -y build-essential autoconf automake libtool pkg-config
        ;;
    *fedora*|*rhel*|*centos*)
        sudo dnf install -y @development-tools autoconf automake libtool pkgconfig gcc make
        ;;
    *)
        echo "Unsupported distro: $ID"; exit 1
        ;;
esac

./autogen.sh
./configure --prefix=/opt/numactl-wasp
make -j"$(nproc)"
sudo make install
sudo ldconfig
sudo ln -sf /opt/numactl-wasp/bin/numactl /usr/local/bin/numactl-wasp
