#!/bin/bash
set -ex

IMAGE_NAME=precurse/security-tools

function docker_test {
    docker run -it $IMAGE_NAME "$@"
}

docker_test nmap --version
docker_test wpscan --version
docker_test gobuster -h
docker_test john
docker_test cewl --help
docker_test ffuf -V
docker_test ncrack --version
docker_test bettercap -version
docker_test responder.py --version
docker_test dnschef.py --help

# RE Image Tests
IMAGE_NAME=precurse/security-tools-re

docker_test binwalk /bin/date
docker_test r2 -version
