FROM ubuntu:16.04

# Install required ubuntu packages
RUN apt-get update && apt-get -y install autoconf curl git libc6-dev-i386 libcurl4-openssl-dev libffi-dev libjpeg8-dev libssl-dev libtool libxml2-dev libxslt1-dev openssl pkg-config python-dev python-pip unzip zlib1g-dev 

# Upgrade pip
RUN pip install --upgrade pip

# Install required pip packages
RUN pip install capstone pefile configobj mitmproxy==0.16

# Clone main repo
WORKDIR /
RUN git clone https://github.com/secretsquirrel/bdfproxy

# Init sub-modules
WORKDIR /bdfproxy
RUN git submodule init && git submodule update
WORKDIR /bdfproxy/bdf/
RUN git pull origin master

# Build osslsigncode
WORKDIR /bdfproxy/bdf/osslsigncode
RUN ./autogen.sh && ./configure && make && make install

# Install aPLib
WORKDIR /bdfproxy/bdf/aPLib/example
RUN gcc -c -I../lib/elf -m32 -Wall -O2 -s -o appack.o appack.c -v && gcc -m32 -Wall -O2 -s -o appack appack.o ../lib/elf/aplib.a -v && cp ./appack /usr/bin/appack

WORKDIR /bdfproxy

CMD ["/bin/bash"]
