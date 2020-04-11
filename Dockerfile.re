FROM precurse/security-tools-base
ENV IMAGEDATE 2020-01-05

WORKDIR /work
COPY ./files/forensics/fernflower .

RUN apt update \
    && apt install -y gradle \
    && gradle build

FROM precurse/security-tools-base

WORKDIR /work

COPY --from=0 /work/build/libs/fernflower.jar /opt/fernflower.jar
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
    # Bindiff
    && curl -SL https://storage.googleapis.com/bindiff-releases/bindiff_6_amd64.deb -o /tmp/bindiff.deb \
    && echo "bindiff bindiff/accepted-bindiff-license boolean true" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt install -y /tmp/bindiff.deb \
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
    && cd /work/forensics/volatility \
    && python2 setup.py install \
    && pip2 install \
        distorm3 \
    && pip3 install \
        frida-tools \
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
    && find /ghidra -name ghidraRun -type f | xargs -I{} ln -s {} /bin/ghidra \
    # Install bindiff plugin
    && unzip -d $(echo ${GHIDRA_VER} | awk -F'_' '{print $1 "_" $2 "_" $3 }')/Ghidra/Extensions/ /opt/bindiff/extra/ghidra/ghidra_BinExport.zip

WORKDIR /ida

RUN curl -SL https://out7.hex-rays.com/files/idafree70_linux.run -o ida.run \
    && chmod +x ida.run \
    && yes y | ./ida.run \
    && mv y/* . \
    && rm ida.run

COPY files/init.sh /init.sh
COPY files/fernflower /usr/local/bin/fernflower


# Tests
RUN binwalk /bin/date \
    && r2 -version \
    && frida --version \
    && python2 /work/forensics/volatility/vol.py -h >/dev/null

CMD ["/bin/bash"]
