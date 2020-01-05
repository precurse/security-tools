FROM precurse/security-tools-base

WORKDIR /tmp

# Get latest version of nmap and convert to .deb package format
RUN apt update && \
    apt install -y alien curl && \
    export NMAP_VER=$(curl https://nmap.org/dist/ 2>/dev/null | awk -F'a href="' '{ print $2 }' | egrep '^nmap-[0-9].*x86_64\.rpm' | awk -F '-' '{print $2}' | sort -r |head -1) && \
    curl -L http://nmap.org/dist/nmap-${NMAP_VER}-1.x86_64.rpm -O && \
    curl -L http://nmap.org/dist/ncat-${NMAP_VER}-1.x86_64.rpm -O && \
    curl -L http://nmap.org/dist/nping-0.${NMAP_VER}-1.x86_64.rpm -O && \
    alien * && rm *.rpm

FROM precurse/security-tools-base

COPY --from=0 /tmp/*.deb /tmp/

WORKDIR /work

RUN dpkg -i /tmp/*.deb \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    hping3 \
    tor \
    proxychains4 \
    # Enumeration
    p0f \
    masscan \
    # Web
    nikto \
    # Attack
    ncrack \
    hydra \
    john \
    cewl \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Ruby apps
RUN gem install \
    wpscan \
    snmp \
  && curl http://www.nothink.org/codes/snmpcheck/snmpcheck-1.9.rb -o /usr/local/bin/snmpcheck \
  && chmod +x /usr/local/bin/snmpcheck

# Python apps
RUN pip3 --no-cache-dir install \
      sqlmap \
      wfuzz \
      scapy \
      dnslib \
      /work/attack/pwntools \
    && curl https://raw.githubusercontent.com/iphelix/dnschef/master/dnschef.py -o /usr/local/bin/dnschef.py \
    && chmod 0755 /usr/local/bin/dnschef.py \
    # Cleanup
    && rm -rf /root/.cache/pip \
    && py3clean /

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

# Compiled apps
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
  && ln -s /work/attack/Responder/Responder.py /usr/local/bin/responder.py \
  && nmap --script-updatedb \
  # Wordlists
  && ln -s /work/wordlists /wordlists

CMD ["/bin/bash"]
