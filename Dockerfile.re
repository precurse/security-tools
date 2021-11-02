FROM precurse/security-tools-base AS fernflower-builder

WORKDIR /work
COPY ./files/forensics/fernflower .

RUN apt update \
    && apt install -y gradle \
    && gradle build

FROM precurse/security-tools-base

WORKDIR /work

COPY --from=fernflower-builder /work/build/libs/fernflower.jar /opt/fernflower.jar
COPY ./files/forensics /work/forensics

RUN apt update \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    openjdk-11-jdk \
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

ENV GHIDRA_VER=10.0.4
ENV GHIDRA_DIR=/ghidra/ghidra_${GHIDRA_VER}_PUBLIC
ENV GHIDRA_DL=https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.0.4_build/ghidra_10.0.4_PUBLIC_20210928.zip

RUN curl -SL ${GHIDRA_DL} -o ghidra.zip \
    && unzip -qq ghidra.zip \
    && rm ghidra.zip \
    # Force Ghidra to foreground
    && find . -name ghidraRun -type f | xargs sed -i 's/bg/fg/g' \
    # Symlink ghidra run to /bin/ghidra
    && find /ghidra -name ghidraRun -type f | xargs -I{} ln -s {} /bin/ghidra \
    # Install bindiff plugin
    && unzip -qq -d ${GHIDRA_DIR}/Ghidra/Extensions/ /opt/bindiff/extra/ghidra/ghidra_BinExport.zip \
    # Bindiff workaround. BinExport has binary path wrong
    && ln -s /opt/bindiff/bin/bindiff /opt/bindiff/bindiff

# Download extra instructions
RUN cd ${GHIDRA_DIR}/Ghidra/Processors \
    && git clone https://github.com/Ebiroll/ghidra-xtensa Xtensa \
    && cd Xtensa \
    && make \
    && chmod -R 0755 .

# Download reference manuals
RUN curl -SL https://www.cs.utexas.edu/~simon/378/resources/ARMv7-AR_TRM.pdf --output "$GHIDRA_DIR/Ghidra/Processors/ARM/data/manuals/Armv7AR_errata.pdf"

# JD-GUI
ENV JDGUI_VER=1.6.6
RUN curl -SL https://github.com/java-decompiler/jd-gui/releases/download/v${JDGUI_VER}/jd-gui-${JDGUI_VER}.jar --output /opt/jd-gui.jar

COPY files/init.sh /init.sh
COPY files/java_run /usr/local/bin/java_run

# Java symlinks
RUN ln -s /usr/local/bin/java_run /usr/local/bin/fernflower \
    && ln -s /usr/local/bin/java_run /usr/local/bin/jd-gui

# Tests
RUN binwalk /bin/date \
    && r2 -version \
    && frida --version \
    && python2 /work/forensics/volatility/vol.py -h >/dev/null

CMD ["/bin/bash"]
