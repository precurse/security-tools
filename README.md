# Security-Tools

[![Build Status](https://travis-ci.com/precurse/security-tools.svg?branch=master)](https://travis-ci.com/precurse/security-tools)

## Description
These are security-related tools contained in a Docker image.

I created this when I wanted a portable environment without running a VM.

## Building image
On each run of `build.sh`, the latest git release tag (if available) will be checked out.
```bash
$ ./build.sh
```

## Language Support
- C (with cross-compile support)
- Python
- Ruby
- Golang
- Perl

## Tools included
- QEMU (Emulation for ARM, MIPS, etc.)
- nmap (with vulscan + vulners)
- binwalk
- bettercap
- gobuster
- ffuf
- scapy
- pwntools
- sqlmap
- wfuzz
- john the ripper
- cewl
- nikto
- wpscan
