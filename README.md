# Security-Tools

[![Build Status](https://travis-ci.com/precurse/security-tools.svg?branch=master)](https://travis-ci.com/precurse/security-tools)

## Description
These are security-related tools contained in a Docker image.

## History
I created this with the following requirements in mind:
- Portability: I wanted a cross-platform way of running my toolset.
- Consistent: I want a fresh environment every time I run my tools.
- Modular: I wanted to make it easy to add or remove packages at runtime or during build.
- Current: Packages should be as close to their current release as possible.

I chose Ubuntu as the base image since it generally has good package support. Arch was an option, since it usually has a good selection of current packages, but I didn't want to rely on the Arch User Repository (AUR) for installing packages.

The repository is setup in a way so builds are as automated as possible, to minimize time spent maintaining the image (i.e. no version pinning). When possible, packages are pulled from the standard Ubuntu repo except in cases where a more current version is desired (nmap, binwalk, ncrack, etc.).

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
### Enumeration / Fingerprinting
- nmap (with vulscan + vulners)
- hping3
- p0f
- masscan
- snmpcheck

### Web
- gobuster
- ffuf
- sqlmap
- nikto
- wfuzz
- wpscan

### Forensics
- binwalk
- bulk_extractor

### Reverse Engineering / Debugging
- apktool
- adb/fastboot (Android)
- QEMU (Emulation for ARM, MIPS, etc.)
- radare2 (with Ghidra decompiler plugin)

### Password Breaking
- cewl
- hashcat
- hydra
- john the ripper
- ncrack

### Sniffing / Spoofing
- bettercap
- scapy
- pwntools
- responder
- dnschef

### Other
- tor
- proxychains-ng

## Usage
### Shell with current working directory mounted inside container
```bash
$ docker run -v `pwd`:`pwd` -w `pwd` -it precurse/security-tools
```

### Bettercap
```bash
$ docker run --privileged --net=host -it precurse/security-tools bettercap
```

### Tor with proxychains
```bash
# Start tor as user nobody
$ su - nobody -s /bin/bash -c 'HOME=/tmp /usr/sbin/tor'

# Default proxychains uses standard tor port
$ proxychains https://ifconfig.me
```

### Using r2ghidra Decompiler
```bash
$ r2 /bin/some_executable
s main
aa # to analyze binary
pdg
```
