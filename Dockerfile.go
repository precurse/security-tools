FROM precurse/security-tools-base

WORKDIR /work

RUN go get -u github.com/tomnomnom/assetfinder \
	&& go get -u github.com/tomnomnom/gron \
	&& go get github.com/tomnomnom/waybackurls \
	&& go get -u github.com/tomnomnom/meg
