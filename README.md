# Security-Tools

[![Build Status](https://travis-ci.com/precurse/security-tools.svg?branch=master)](https://travis-ci.com/precurse/security-tools)

## Description
These are security-related tools contained in a Docker image.

I created this so I can have a disposable/portable environment without running a heavy VM.

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
### Enumeration
- nmap (with vulscan + vulners)
- hping3
- p0f
- masscan

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
