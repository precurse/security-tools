IMAGE_RE="precurse/security-tools-re"
IMAGE_TOOLS="precurse/security-tools"
IMAGE_BETTERCAP="bettercap/bettercap"
IMAGE_GO="precurse/security-tools-go"
IMAGE_RECON="precurse/security-tools-recon"
IMAGE_PROXY="precurse/security-tools-proxy"
IMAGE_BROWSER="precurse/security-tools-browser"
IMAGE_GODEV="precurse/security-tools-godev"               # Go Development

# Wordlists
WL_DIRMED="/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"

DOCKER_CMD="podman run"

# Functions
function dockershell { $DOCKER_CMD --rm -v "$(pwd)":"$(pwd)":Z -w "$(pwd)" -it $IMAGE_TOOLS "$@";}
function dockershell_5000 { $DOCKER_CMD --rm -v "$(pwd)":"$(pwd)":Z -p 5000:5000 -w "$(pwd)" -it $IMAGE_TOOLS "$@";}
function dockershell_re { $DOCKER_CMD --rm -v "$(pwd)":"$(pwd)":Z -w "$(pwd)" -it $IMAGE_RE "$@";}
function go { $DOCKER_CMD --rm -v "$(pwd)":"$(pwd)":Z -w "$(pwd)" -it $IMAGE_GODEV "go" "$@";}

## Special Docker flags
function tor_cli { $DOCKER_CMD --rm -p 127.0.0.1:9050:9050 -it $IMAGE_TOOLS ${@-tor_cli};}
function fernflower { $DOCKER_CMD --rm -v "$(pwd)":"$(pwd)":Z -w "$(pwd)" -it $IMAGE_RE java -jar /opt/fernflower.jar "$@"; }

## Privileged commands
function android { $DOCKER_CMD --rm --privileged --net=none -v "$(pwd)":"$(pwd)":Z -w "$(pwd)" -v /dev/bus/usb:/dev/bus/usb:Z -it $IMAGE_RE "${@-adb}"; }
function p0f { $DOCKER_CMD --rm --privileged --net=host -it $IMAGE_TOOLS  "p0f" "$@"; }
function bettercap { $DOCKER_CMD --rm --privileged --net=host -it $IMAGE_BETTERCAP "$@"; }

# Unprivileged functions
function d_unpriv_tools { $DOCKER_CMD --rm --user nobody -i $IMAGE_TOOLS "$@"; }
function d_unpriv_go { $DOCKER_CMD --rm --user nobody -i $IMAGE_GO "$@"; }

# Aliases
alias amass="dockershell amass"
alias binwalk="dockershell_re binwalk"
alias bulk_extractor="dockershell_re bulk_extractor"
alias masscan="dockershell masscan"
alias nmap="dockershell nmap"
alias snmpcheck="dockershell snmpcheck"
alias wpscan="dockershell wpscan"

## Unprivileged aliases
alias assetfinder="d_unpriv_go assetfinder"
alias cewl="d_unpriv_tools cewl"
alias ffuf="d_unpriv_tools ffuf"
alias gobuster="d_unpriv_tools gobuster"
alias gron="d_unpriv_go gron"
alias meg="d_unpriv_go meg"
alias nikto="d_unpriv_tools nikto"
alias ncrack="d_unpriv_tools ncrack"
alias sqlmap="d_unpriv_tools sqlmap"
alias waybackurls="d_unpriv_go waybackurls"
alias wfuzz="d_unpriv_tools wfuzz"

alias ffufq="d_unpriv_tools ffuf -w $WL_DIRMED -u"
alias ffufqr="d_unpriv_tools ffuf -w $WL_DIRMED -recursion -u"

# Shodan needs a stateful API key
function shodan {
    mkdir -p ~/.config/shodan
    $DOCKER_CMD --rm \
    --user $(id -u):$(id -g) \
    -v $HOME/.config/shodan:$HOME/.config/shodan \
    -e HOME=$HOME \
    -e USER=$USERNAME \
    -it $IMAGE_TOOLS "shodan" "$@";
}


function ghidra {
    mkdir -p ~/.ghidra ~/.bindiff ~/ghidra_projects
    $DOCKER_CMD \
        -v ${PWD}:/data \
        --rm \
        --network none \
        --entrypoint=/init.sh \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
        -v $HOME/.ghidra:$HOME/.ghidra:Z \
        -v $HOME/.bindiff:$HOME/.bindiff:Z \
        -v $HOME/ghidra_projects:$HOME/ghidra_projects:Z \
        -v "$(pwd)":"$(pwd)":Z \
        -w "$(pwd)" \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -it $IMAGE_RE "${@-ghidra}";
    }

function ida {
    $DOCKER_CMD \
        --rm \
        -v ${PWD}:/data \
        --network none \
        --entrypoint=/init.sh \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
        -v "$(pwd)":"$(pwd)" \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -it $IMAGE_RE "${@-/ida/ida64}";
    }

function jd-gui {
    $DOCKER_CMD \
        -v ${PWD}:/data \
        --rm \
        --network none \
        --entrypoint=/init.sh \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
        -v "$(pwd)":"$(pwd)" \
        -w "$(pwd)" \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -it $IMAGE_RE "${@-jd-gui}";
    }

function dfirefox {
    if [ "$1" = "burp" ];
    then
        FLAGS=$(cat <<-END
            -e http_proxy=http://127.0.0.1:8080
            -e HTTP_PROXY=http://127.0.0.1:8080
            -e https_proxy=http://127.0.0.1:8080
            -e HTTPS_PROXY=http://127.0.0.1:8080
            --net=container:burpsuite
END
)
    else
        FLAGS=
    fi

    $DOCKER_CMD \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
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
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
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
        -it $IMAGE_TOOLS tor;

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
        -it $IMAGE_TOOLS "${@-/bin/bash}";
}

function dtorgui {
    $DOCKER_CMD \
        -d \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        -e socks_proxy=socks://127.0.0.1:9050 \
        -e SOCKS_PROXY=socks://127.0.0.1:9050 \
        -e all_proxy=socks://127.0.0.1:9050 \
        -e ALL_PROXY=socks://127.0.0.1:9050 \
        --name=torfox \
        -it $IMAGE_BROWSER "${@-firefox}";

    $DOCKER_CMD \
        --rm \
        --user=nobody \
        -e HOME=/tmp \
        --name tor \
        --net="container:torfox" \
        -it $IMAGE_TOOLS tor;

}

function reguipriv {
    $DOCKER_CMD \
        --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:Z \
        --privileged \
        --net=none \
        -e UID=$(id -u) \
        -e GID=$(id -g) \
        -e USER=$USERNAME \
        --name regui \
        -it $IMAGE_RE "${@-/bin/bash}";
}
