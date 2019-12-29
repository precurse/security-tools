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

COPY ./files/forensics/binwalk/deps.sh /tmp/deps.sh
WORKDIR /work

RUN dpkg -i /tmp/*.deb \
    # apt-key requires gnupg
    && apt update \
    && apt install -y gnupg \
    # Add golang repo
    && echo "deb http://ppa.launchpad.net/longsleep/golang-backports/ubuntu bionic main" > \
        /etc/apt/sources.list.d/golang.list \
    && apt-key adv --recv-key --keyserver keyserver.ubuntu.com F6BC817356A3D45E \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    # Base tools
    git \
    vim \
    tmux \
    wget \
    curl \
    less \
    cpio \
    sudo \
    bsdmainutils \
    net-tools \
    iputils-ping \
    wireless-tools \
    # Build/Libraries
    autoconf \
    automake \
    bison \
    flex \
    libxml2-dev \
    build-essential \
    liblzma-dev \
    zlib1g-dev \
    liblzo2-dev \
    libncurses5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libusb-1.0 \
    libpcap-dev \
    libnetfilter-queue-dev \
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
    # Attack
    ncrack \
    hydra \
    john \
    cewl \
    # Languages
    golang-go \
    ruby \
    ruby-dev \
    python \
    python-pip \
    python-lzma \
    python3 \
    python3-distutils \
    # cramfs binwalk dependency
    && wget http://mirrors.kernel.org/ubuntu/pool/universe/c/cramfs/cramfsprogs_1.1-6ubuntu1_amd64.deb -O /tmp/cramfs.deb \
    && dpkg -i /tmp/cramfs.deb \
    # Install binwalk + dependencies
    && DEBIAN_FRONTEND=noninteractive \
    /tmp/deps.sh --yes \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY ./files/ /work

# Bulk Extractor
RUN cd forensics/bulk_extractor \
  && bash bootstrap.sh \
  && ./configure \
  && make \
  && make install \
  && make clean

# Ruby apps
RUN gem install wpscan

# Python apps
RUN cd /work/forensics/binwalk \
    && python3 setup.py install \
    && pip3 --no-cache-dir install \
      sqlmap \
      wfuzz \
      scapy \
      /work/attack/pwntools \
    # Cleanup
    && rm -rf /root/.cache/pip \
    && py3clean /

# Golang apps
ENV PATH="/go/bin:${PATH}"
ENV GOPATH="/go"

RUN go get github.com/OJ/gobuster \
  && go get github.com/ffuf/ffuf \
  && cd ./attack/bettercap \
  && make build \
  && make install \
  && make clean \
  # Cleanup
  && rm -rf /root/.cache/go-build \
  && rm -rf $GOPATH/pkg \
  && rm -rf $GOPATH/src

RUN cd ./attack/ncrack \
  && ./configure \
  && make \
  && make install \
  && make clean

# Symlinks
RUN ln -s /work/enumeration/nmap-script-vulscan /usr/share/nmap/scripts/vulscan \
  && ln -s /work/enumeration/nmap-script-vulners/http-vulners-regex.nse /usr/share/nmap/scripts/ \
  && ln -s /work/enumeration/http-vulners-regex.json /usr/share/nmap/nselib/data \
  && ln -s /work/enumeration/http-vulners-paths.txt /usr/share/nmap/nselib/data \
  && nmap --script-updatedb \
  # Wordlists
  && ln -s /work/wordlists /wordlists

ENTRYPOINT ["/bin/bash"]
