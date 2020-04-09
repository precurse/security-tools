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
```bash
$ ./build.sh
```

### Build with latest packages
The latest git release tag (if available) will be checked out.

```bash
$ ./build.sh update
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
- amass

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
- volatility

### Reverse Engineering / Debugging
- apktool
- adb/fastboot (Android)
- QEMU (Emulation for ARM, MIPS, etc.)
- radare2 (with Ghidra decompiler plugin)
- Frida
- Distorm3

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
host$ docker run -v `pwd`:`pwd` -w `pwd` -it precurse/security-tools
```

### Bettercap
```bash
host$ source source.sh
host$ bettercap
```

### Tor with proxychains
```bash
host$ source source.sh
host$ tor_cli

# Default proxychains uses standard tor port
$ proxychains curl https://ifconfig.me
```

### Guidra (GUI)
*Note:* This has only been tested on Linux since an X11 server is built in.
This may require tweaking for other operating systems.

To keep a persistent Ghidra state, create a `.ghidra` and `ghidra_projects` folder in your home directory.
Then have Docker mount these as volumes within the Ghidra container. This is entirely optional.

The following example will disable all network access for Ghidra:

```bash
host$ mkdir ~/.ghidra ~/ghidra_projects
host$ source source.sh
host$ ghidra
```

### Using r2ghidra Decompiler
```bash
host$ docker run -v `pwd`:`pwd` -w `pwd` -it precurse/security-tools-re
docker$ r2 /bin/some_executable
s main
aa # to analyze binary
pdg
```

### Using fernflower Java decompiler
```bash
host$ source source.sh
host$ fernflower lib/*.jar source/
```
