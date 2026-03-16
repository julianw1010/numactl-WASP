sudo apt-get update
sudo apt-get install -y build-essential autoconf automake libtool pkg-config
./autogen.sh
./configure --prefix=/opt/numactl-wasp
make -j$(nproc)
sudo make install
sudo ldconfig
sudo ln -s /opt/numactl-wasp/bin/numactl /usr/local/bin/numactl-wasp
