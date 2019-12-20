FROM ubuntu:18.04

RUN apt update && \
    apt install -y python-pip libcurl4-openssl-dev libssl-dev && \
    pip install pipenv

COPY . /work
WORKDIR /work

RUN pipenv install

ENTRYPOINT ["/bin/bash"]
