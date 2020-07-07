FROM precurse/security-tools-base

ENV CGO_ENABLED 1

WORKDIR /work

RUN go get golang.org/x/net/html \
	&& go get -u github.com/gocolly/colly/... \
	&& go get github.com/mattn/go-sqlite3
