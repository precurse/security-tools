#!/bin/bash
set -ex

function get_latest_release {
    pushd files/$1
    git fetch --tags
    TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
    git checkout $TAG
    popd
}

# Ensure submodules updated
git submodule update --init --recursive

# Get latest releases of all submodules
get_latest_release forensics/binwalk
get_latest_release forensics/bulk_extractor
get_latest_release attack/bettercap
get_latest_release attack/ncrack
get_latest_release attack/pwntools
get_latest_release wordlists/seclists

sudo docker build -t precurse/security-tools .
