FROM precurse/security-tools-base

WORKDIR /work

RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    hping3 \
    tor \
    proxychains4 \
    # Enumeration
    nmap \
    p0f \
    masscan \
    # Web
    nikto \
    # Attack
    ncrack \
    hydra \
    john \
    cewl \
    hashcat \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY ./files/attack /work/attack
COPY ./files/enumeration /work/enumeration
COPY ./files/wordlists /work/wordlists

# Ruby apps
RUN gem install \
    wpscan \
    snmp \
  && curl http://www.nothink.org/codes/snmpcheck/snmpcheck-1.9.rb -o /usr/local/bin/snmpcheck \
  && chmod +x /usr/local/bin/snmpcheck

# Python apps
RUN pip3 --no-cache-dir install \
      shodan \
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

# Gobuster/ffuf need access to wordlists
RUN go get github.com/OJ/gobuster \
  && go get github.com/ffuf/ffuf \
  && cd /work/enumeration/amass \
  && go install ./... \
  # Cleanup
  && rm -rf /root/.cache/go-build \
  && rm -rf $GOPATH/pkg \
  && rm -rf $GOPATH/src

# Symlinks
RUN ln -s /work/enumeration/nmap-script-vulscan /usr/share/nmap/scripts/vulscan \
  && ln -s /work/enumeration/nmap-script-vulners/http-vulners-regex.nse /usr/share/nmap/scripts/ \
  && ln -s /work/enumeration/http-vulners-regex.json /usr/share/nmap/nselib/data \
  && ln -s /work/enumeration/http-vulners-paths.txt /usr/share/nmap/nselib/data \
  && ln -s /work/attack/Responder/Responder.py /usr/local/bin/responder.py \
  && nmap --script-updatedb \
  # Wordlists
  && ln -s /work/wordlists /wordlists \
  && ln -s /go/bin/* /usr/local/bin

# Tests
RUN nmap --version \
    && wpscan --version \
    && gobuster -h \
    && john \
    && cewl --help \
    && ffuf -V \
    && ncrack --version \
    && responder.py --version \
    && dnschef.py --help \
    && amass --version

COPY files/tor_cli /usr/local/bin/tor_cli
COPY files/init.sh /init.sh

CMD ["/bin/bash"]
