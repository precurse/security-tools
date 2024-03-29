#!/bin/bash
set -ex

function get_latest_release {
    pushd "files/$1"

    if [ ! -z "${2}" ]
    then
        git checkout "${2}";
        git fetch --depth=1;
    else
        git fetch --tags --force
        BADTAGS='continuous'
        TAG=$(git describe --tags `git rev-list --tags --max-count=5`|grep -Ev "$BADTAGS"|head -1)
        git checkout "${TAG}"
    fi
    popd
}

# Ensure submodules updated
git submodule update --init --recursive

if [ ${1-none} == "update" ]
then
    # Get latest releases of all submodules
    get_latest_release enumeration/amass
    get_latest_release forensics/fernflower master
    get_latest_release forensics/volatility
    get_latest_release forensics/bulk_extractor
    get_latest_release attack/ncrack
    get_latest_release attack/pwntools
    get_latest_release attack/Responder
    get_latest_release wordlists/seclists
    get_latest_release onekey-sec/unblob
fi

podman build -t precurse/security-tools-base -f Dockerfile.base .
podman build -t precurse/security-tools-re -f Dockerfile.re .
podman build -t precurse/security-tools -f Dockerfile .
podman build -t precurse/security-tools-proxy -f Dockerfile.proxy .
podman build -t precurse/security-tools-browser -f Dockerfile.browser .
podman build -t precurse/security-tools-go -f Dockerfile.go .
podman build -t precurse/security-tools-qemu -f Dockerfile.qemu .
