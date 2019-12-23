FROM ubuntu:19.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    net-tools \
    iputils-ping \
    python \
    python-pip \
    python-lzma \
    python3 \
    python3-distutils \
    libcurl4-openssl-dev \
    libssl-dev \
    cpio \
    bsdmainutils \
    less
    #    binwalk

COPY . /work
WORKDIR /work

RUN cd forensics/binwalk && \
      python3 setup.py install && \
      pip install cstruct && \
    cd /work/forensics/jefferson && \
    python setup.py install


ENTRYPOINT ["/bin/bash"]
