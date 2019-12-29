#!/bin/bash
set -ex
bash build.sh
git tag $(date +%Y-%m-%d)
