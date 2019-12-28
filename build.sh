#!/bin/bash
git submodule update --init --recursive
sudo docker build -t precurse/security-tools .
