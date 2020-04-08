FROM precurse/security-tools-base
ENV IMAGEDATE 2020-01-05

WORKDIR /work

COPY ./files/forensics /work/forensics

RUN apt update \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    gdb \
    gdb-multiarch \
    gcc-multilib-mips-linux-gnu \
    binutils-arm-linux-gnueabi \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    # Emulation
    qemu-user-static \
    apktool \
    android-tools-adb \
    android-tools-fastboot \
    # cramfs binwalk dependency
    && wget http://mirrors.kernel.org/ubuntu/pool/universe/c/cramfs/cramfsprogs_1.1-6ubuntu1_amd64.deb -O /tmp/cramfs.deb \
    && dpkg -i /tmp/cramfs.deb \
    # Install binwalk + dependencies
    && DEBIAN_FRONTEND=noninteractive \
    /work/forensics/binwalk/deps.sh --yes \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*


# Bulk Extractor
RUN cd forensics/bulk_extractor \
  && bash bootstrap.sh \
  && ./configure \
  && make \
  && make install \
  && make clean

# Python apps
RUN cd /work/forensics/binwalk \
    && python3 setup.py install \
    && pip3 install frida-tools \
    # Cleanup
    && rm -rf /root/.cache/pip \
    && py3clean /

# Compiled apps
RUN cd /work/forensics/radare2 \
  && ./configure \
  && make \
  && make install \
  && make clean \
  && r2pm init \
  # Ghira decompiler
  && r2pm -i r2ghidra-dec

# Ghidra
WORKDIR /ghidra

ENV GHIDRA_VER=ghidra_9.1.2_PUBLIC_20200212

RUN curl -SL https://ghidra-sre.org/${GHIDRA_VER}.zip -o ghidra.zip \
    && unzip ghidra.zip \
    && rm ghidra.zip \
    # Force Ghidra to foreground
    && find . -name ghidraRun -type f | xargs sed -i 's/bg/fg/g' \
    # Symlink ghidra run to /bin/ghidra
    && find /ghidra -name ghidraRun -type f | xargs -I{} ln -s {} /bin/ghidra

COPY files/init.sh /init.sh

# Tests
RUN binwalk /bin/date \
    && r2 -version \
    && frida --version

CMD ["/bin/bash"]
