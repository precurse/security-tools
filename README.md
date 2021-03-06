# Security-Tools

[![Build Status](https://travis-ci.com/precurse/security-tools.svg?branch=master)](https://travis-ci.com/precurse/security-tools)

## Description
These are security-related tools contained in a Docker image.

Tools are configured to require least privilege. For some applications that means no network access at all (i.e. Ghidra), while others need network and user `nobody` (i.e. gobuster, ffuf, etc.)

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

### Enumeration / Fingerprinting / Recon
- amass
- assetfinder
- hping3
- masscan
- meg
- nmap (with vulscan + vulners)
- p0f
- snmpcheck
- waybackurls

### Web
- ffuf
- gobuster
- nikto
- sqlmap
- wfuzz
- wpscan

### Forensics
- binwalk
- bulk_extractor
- volatility

### Reverse Engineering / Debugging
- adb/fastboot (Android)
- apktool
- Bindiff
- Distorm3
- Frida
- JD-GUI (Java Decompiler)
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
- dnschef
- pwntools
- responder
- scapy

### Other
- tor
- proxychains-ng

## Usage
### Shell with current working directory mounted inside container
```bash
host$ source source.sh
host$ dockershell
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

### Android Debugging
```bash
host$ android adb
# or
host$ android fastboot
```

### r2ghidra Decompiler
```bash
host$ source source.sh
host$ dockershell_re
docker$ r2 /bin/some_executable
s main
aa # to analyze binary
pdg
```

### Fernflower Java decompiler
```bash
host$ source source.sh
host$ fernflower lib/*.jar source/
```

### GUI Apps
*Note:* These has only been tested on Linux since an X11 server is built in.
This may require tweaking for other operating systems.

#### Guidra
To keep a persistent Ghidra state, create a `.ghidra` and `ghidra_projects` folder in your home directory.
Then have Docker mount these as volumes within the Ghidra container. This is entirely optional.

The following example will disable all network access for Ghidra:

```bash
host$ mkdir ~/.ghidra ~/ghidra_projects
host$ source source.sh
host$ ghidra
```

#### IDA Free
```bash
host$ source source.sh
host$ ida
```

#### Firefox
This will launch a disposable Firefox.
```bash
host$ source source.sh
host$ dfirefox
```

#### BurpSuite Community
This will launch Burp listening on 127.0.0.1:8080 on your host.
```bash
host$ source source.sh
host$ dburp
```

#### Firefox + BurpSuite Community
This will launch burp and Firefox together. All HTTP requests will go through Burp.

```bash
host$ source source.sh
host$ dproxy
```
