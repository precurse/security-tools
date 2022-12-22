alias gowitness="podman run --rm -v $(pwd):/data:Z -it ghcr.io/sensepost/gowitness:latest gowitness"
alias gowitness-serve="podman run -d --rm --net host -p7171:7171 -v $(pwd):/data:Z -it ghcr.io/sensepost/gowitness:latest gowitness report serve --address :7171"

# Project Discovery
alias httpx="podman run -i docker.io/projectdiscovery/httpx"
alias nuclei="podman run --rm -v $HOME/nuclei-templates:/root/nuclei-templates:Z -i docker.io/projectdiscovery/nuclei"
