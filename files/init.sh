#!/bin/bash
set -e
USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}
USER_NAME=${USER:-docker_user}

# Create user + homedir
useradd -s /bin/bash -m -u ${USER_ID} ${USER_NAME}

echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker

# Set proper
export HOME=$(eval echo ~$USER_NAME)

# Drop privs and preserve env
if [ -z "$1" ]
then
    su -m ${USER_NAME}
else
    su -m ${USER_NAME} -c '"$1"' bash $@
fi