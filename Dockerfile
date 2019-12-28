FROM ubuntu:19.04
ENV IMAGEDATE 2019-12-28

WORKDIR /tmp

# Get latest version of nmap and convert to .deb package format
RUN apt update && \
    apt install -y alien curl && \
    export NMAP_VER=$(curl https://nmap.org/dist/ 2>/dev/null | awk -F'a href="' '{ print $2 }' | egrep '^nmap-[0-9].*x86_64\.rpm' | awk -F '-' '{print $2}' | sort -r |head -1) && \
    curl -L http://nmap.org/dist/nmap-${NMAP_VER}-1.x86_64.rpm -O && \
    curl -L http://nmap.org/dist/ncat-${NMAP_VER}-1.x86_64.rpm -O && \
    curl -L http://nmap.org/dist/nping-0.${NMAP_VER}-1.x86_64.rpm -O && \
    alien * && rm *.rpm

FROM ubuntu:19.04

COPY --from=0 /tmp/*.deb /tmp/

RUN dpkg -i /tmp/*.deb && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    # Base tools
    git \
    vim \
    wget \
    curl \
    less \
    cpio \
    sudo \
    bsdmainutils \
    net-tools \
    iputils-ping \
    # Building/Debugging
    build-essential \
    liblzma-dev \
    zlib1g-dev \
    liblzo2-dev \
    libncurses5-dev \
    gdb \
    gdb-multiarch \
    gcc-multilib-mips-linux-gnu \
    binutils-arm-linux-gnueabi \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    # Emulation
    qemu-user-static \
    # Web
    nikto \
    # Python
    python \
    python-pip \
    python-lzma \
    python3 \
    python3-distutils \
    libcurl4-openssl-dev \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

COPY ./files/ /work
WORKDIR /work

RUN wget http://mirrors.kernel.org/ubuntu/pool/universe/c/cramfs/cramfsprogs_1.1-6ubuntu1_amd64.deb -O /tmp/cramfs.deb && \
    dpkg -i /tmp/cramfs.deb && \
    rm -rf /tmp/* && \
    DEBIAN_FRONTEND=noninteractive \
    ./forensics/binwalk/deps.sh --yes && \
    cd forensics/binwalk && \
    python3 setup.py install && \
    pip3 install \
      capstone \
      sqlmap \
      wfuzz \
      scapy && \
    cd /work/enumeration/nmap-script-vulscan && git pull && \
    cd /work/enumeration/nmap-script-vulners && git pull && \
    ln -s /work/enumeration/nmap-script-vulscan /usr/share/nmap/scripts/vulscan && \
    ln -s /work/enumeration/nmap-script-vulners/http-vulners-regex.nse /usr/share/nmap/scripts/ && \
    ln -s /work/enumeration/http-vulners-regex.json /usr/share/nmap/nselib/data && \
    ln -s /work/enumeration/http-vulners-paths.txt /usr/share/nmap/nselib/data && \
    nmap --script-updatedb


ENTRYPOINT ["/bin/bash"]
