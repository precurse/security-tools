FROM precurse/security-tools-base

ENV CGO_ENABLED 1

WORKDIR /work

RUN go get golang.org/x/net/html \
	&& go get -u google.golang.org/api/sheets/v4 \
	&& go get -u golang.org/x/oauth2/google \
	&& go get -u github.com/gocolly/colly/... \
	&& go get github.com/mattn/go-sqlite3
