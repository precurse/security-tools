IMAGE_RE="precurse/security-tools-re"
IMAGE_T="precurse/security-tools"

DOCKER_CMD="sudo docker run"

function dockershell { $DOCKER_CMD -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_T "$@";}
function dockershell_re { $DOCKER_CMD -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_RE "$@";}

# cmds with special Docker flags
function android { $DOCKER_CMD --privileged --net=none -v "$(pwd)":"$(pwd)" -w "$(pwd)" -v /dev/bus/usb:/dev/bus/usb -it $IMAGE_RE "${@-adb}"; }
function bettercap { $DOCKER_CMD --privileged --net=host -it $IMAGE_T "${@-bettercap}"; }
function tor_cli { $DOCKER_CMD -it $IMAGE_T ${@-tor_cli};}
function fernflower { $DOCKER_CMD -v "$(pwd)":"$(pwd)" -w "$(pwd)" -it $IMAGE_RE java -jar /opt/fernflower.jar "$@"; }

function ghidra {
    $DOCKER_CMD \
        -v ${PWD}:/data \
        --network none \
        --entrypoint=/init.sh \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME/.ghidra:$HOME/.ghidra \
        -v $HOME/work/ghidra_projects:$HOME/ghidra_projects \
        -v "$(pwd)":"$(pwd)" \
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
