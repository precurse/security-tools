IMAGE_RE="precurse/security-tools-re"
IMAGE_T="precurse/security-tools"
IMAGE_GO="precurse/security-tools-go"
IMAGE_PROXY="precurse/security-tools-proxy"
IMAGE_BROWSER="precurse/security-tools-browser"

DOCKER_CMD="sudo docker run"

function dockershell { $DOCKER_CMD -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_T "$@";}
function dockershell_re { $DOCKER_CMD -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_RE "$@";}

function go { $DOCKER_CMD --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_GO "go" "$@";}

# cmds with special Docker flags
function android { $DOCKER_CMD --privileged --net=none -v "$(pwd)":"$(pwd)" -w "$(pwd)" -v /dev/bus/usb:/dev/bus/usb -it $IMAGE_RE "${@-adb}"; }
function bettercap { $DOCKER_CMD --privileged --net=host -it $IMAGE_T "${@-bettercap}"; }
function tor_cli { $DOCKER_CMD -it $IMAGE_T ${@-tor_cli};}
function fernflower { $DOCKER_CMD -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_RE java -jar /opt/fernflower.jar "$@"; }

alias binwalk="dockershell_re binwalk"

function ghidra {
    mkdir -p ~/.ghidra ~/.bindiff ~/work/ghidra_projects
    $DOCKER_CMD \
        -v ${PWD}:/data \
        --network none \
        --entrypoint=/init.sh \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME/.ghidra:$HOME/.ghidra \
        -v $HOME/.bindiff:$HOME/.bindiff \
        -v $HOME/work/ghidra_projects:$HOME/ghidra_projects \
        -v "$(pwd)":"$(pwd)" \
        -w "$(pwd)" \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -it $IMAGE_RE "${@-ghidra}";
    }

function ida {
    $DOCKER_CMD \
        -v ${PWD}:/data \
        --network none \
        --entrypoint=/init.sh \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v "$(pwd)":"$(pwd)" \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -it $IMAGE_RE "${@-/ida/ida64}";
    }

function dfirefox {
    if [ "$1" = "burp" ];
    then
        FLAGS=$(cat <<-END
            -e http_proxy=http://127.0.0.1:8080
            -e HTTP_PROXY=http://127.0.0.1:8080
            -e https_proxy=https://127.0.0.1:8080
            -e HTTPS_PROXY=https://127.0.0.1:8080
            --net=container:burpsuite
END
)
    else
        FLAGS=
    fi

    $DOCKER_CMD \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        --name firefox $FLAGS \
        --memory "4g" \
        --shm-size "1g" \
        -it $IMAGE_BROWSER "firefox";
}

function dburp {
    # If no arguments given, use host networking
    if [ "$1" = "container" ];
    then
        FLAGS=
    else
        FLAGS="--net=host"
    fi

    mkdir -p ~/.BurpSuite
    $DOCKER_CMD \
        -d \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v $HOME/.BurpSuite:$HOME/.BurpSuite \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e 8080 \
        -p 127.0.0.1:8080:8080 \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME $FLAGS \
        --name=burpsuite \
        -it $IMAGE_PROXY "/start_proxy.sh";
}

function dproxy {
    dburp container
    dfirefox burp
}

function dtor {
    $DOCKER_CMD \
        -d \
        --rm \
        --user=nobody \
        -e HOME=/tmp \
        --name tor \
        -it $IMAGE_T tor;

    $DOCKER_CMD \
        --rm \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -e http_proxy=socks5h://127.0.0.1:9050 \
        -e HTTP_PROXY=socks5h://127.0.0.1:9050 \
        -e https_proxy=socks5h://127.0.0.1:9050 \
        -e HTTPS_PROXY=socks5h://127.0.0.1:9050 \
        -e all_proxy=socks5h://127.0.0.1:9050 \
        -e all_proxy=socks5h://127.0.0.1:9050 \
        --net="container:tor" \
        --name proxy-client \
        -it $IMAGE_T "${@-/bin/bash}";
}

function dtorgui {
    $DOCKER_CMD \
        -d \
        --rm \
        --user=nobody \
        -e HOME=/tmp \
        --name tor \
        -it $IMAGE_T tor;

    $DOCKER_CMD \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -e http_proxy=socks5h://127.0.0.1:9050 \
        -e HTTP_PROXY=socks5h://127.0.0.1:9050 \
        -e https_proxy=socks5h://127.0.0.1:9050 \
        -e HTTPS_PROXY=socks5h://127.0.0.1:9050 \
        -e all_proxy=socks5h://127.0.0.1:9050 \
        -e all_proxy=socks5h://127.0.0.1:9050 \
        --net="container:tor" \
        --name proxy-client \
        -it $IMAGE_BROWSER "${@-firefox}";
}

function reguipriv {
    $DOCKER_CMD \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --privileged \
        --net=none \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        --name regui \
        -it $IMAGE_RE "${@-/bin/bash}";
}
