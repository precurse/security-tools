#!/bin/bash
docker run --user ${UID}:$(id -g) -v ${PWD}:/data -it security-tools
