sudo apt-get update
sudo apt-get install -y build-essential autoconf automake libtool pkg-config
./autogen.sh
./configure
make -j$(nproc)
sudo make install
ldconfig
