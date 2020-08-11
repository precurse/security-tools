FROM precurse/security-tools-base AS fernflower-builder

WORKDIR /work
COPY ./files/forensics/fernflower .

RUN apt update \
    && apt install -y gradle \
    && gradle build

FROM precurse/security-tools-base AS qemu-builder

WORKDIR /qemu-build

RUN export QEMU_VER=$(curl https://download.qemu.org 2>/dev/null | awk -F'a href="' '{ print $2 }' | awk -F'">' '{print $1}' |grep -E '^qemu-.*.tar.xz$' |grep -Ev 'rc[0-9].tar.xz' |tail -1 | sed 's/.tar.xz//g')  \
    && curl https://download.qemu.org/$QEMU_VER.tar.xz -o qemu.tar.xz \
    && tar xf qemu.tar.xz \
    && mv $QEMU_VER/* . \
    && rm qemu.tar.xz \
    && apt update \
    && apt install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev \
    && ./configure \
        --prefix=/qemu \
        --static \
        --disable-system \
        --enable-linux-user \
    && make -j4 \
    && make install


FROM precurse/security-tools-base

WORKDIR /work

COPY --from=fernflower-builder /work/build/libs/fernflower.jar /opt/fernflower.jar
COPY --from=qemu-builder /qemu/bin/* /usr/local/bin/
COPY ./files/forensics /work/forensics

RUN apt update \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    openjdk-11-jdk-headless \
    gdb \
    gdb-multiarch \
    binutils-arm-linux-gnueabi \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    apktool \
    android-tools-adb \
    android-tools-fastboot \
    radare2 \
    binwalk \
    openocd \
    # Bindiff
    && curl -SL https://storage.googleapis.com/bindiff-releases/bindiff_6_amd64.deb -o /tmp/bindiff.deb \
    && echo "bindiff bindiff/accepted-bindiff-license boolean true" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt install -y /tmp/bindiff.deb \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

WORKDIR /ida

RUN curl -SL https://out7.hex-rays.com/files/idafree70_linux.run -o ida.run \
    && chmod +x ida.run \
    && yes y | ./ida.run \
    && mv y/* . \
    && rm ida.run

WORKDIR /work

# Bulk Extractor
RUN cd forensics/bulk_extractor \
  && bash bootstrap.sh \
  && ./configure \
  && make \
  && make install \
  && make clean

# Python apps
RUN cd /work/forensics/volatility \
    && python3 setup.py install \
    && pip3 install \
        frida-tools \
        qiling \
        distorm3 \
    # Cleanup
    && rm -rf /root/.cache/pip \
    && py3clean /

# Ghidra
WORKDIR /ghidra

ENV GHIDRA_VER=ghidra_9.1.2_PUBLIC_20200212

RUN curl -SL https://ghidra-sre.org/${GHIDRA_VER}.zip -o ghidra.zip \
    && unzip -qq ghidra.zip \
    && rm ghidra.zip \
    # Force Ghidra to foreground
    && find . -name ghidraRun -type f | xargs sed -i 's/bg/fg/g' \
    # Symlink ghidra run to /bin/ghidra
    && find /ghidra -name ghidraRun -type f | xargs -I{} ln -s {} /bin/ghidra \
    # Install bindiff plugin
    && unzip -qq -d $(echo ${GHIDRA_VER} | awk -F'_' '{print $1 "_" $2 "_" $3 }')/Ghidra/Extensions/ /opt/bindiff/extra/ghidra/ghidra_BinExport.zip \
    # Bindiff workaround. BinExport has binary path wrong
    && ln -s /opt/bindiff/bin/bindiff /opt/bindiff/bindiff


# Download reference manuals
RUN GHIDRA_VER_SHORT=`echo ${GHIDRA_VER} | awk -F'_' '{print $1 "_" $2 "_" $3 }'` \
    && curl -SL https://www.cs.utexas.edu/~simon/378/resources/ARMv7-AR_TRM.pdf --output "$GHIDRA_VER_SHORT/Ghidra/Processors/ARM/data/manuals/Armv7AR_errata.pdf"

COPY files/init.sh /init.sh
COPY files/fernflower /usr/local/bin/fernflower

# Tests
RUN binwalk /bin/date \
    && r2 -version \
    && frida --version \
    && python2 /work/forensics/volatility/vol.py -h >/dev/null

CMD ["/bin/bash"]
