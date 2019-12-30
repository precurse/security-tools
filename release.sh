#!/bin/bash
set -ex
DATE_TAG=$(date +%Y-%m-%d)
bash build.sh
sudo docker tag precurse/security-tools precurse/security-tools:${DATE_TAG}
git tag ${DATE_TAG}
