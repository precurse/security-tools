#!/bin/bash
set -e
USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}
USER_NAME=${USER:-docker_user}

# Create user + homedir
useradd -s /bin/bash -m -u ${USER_ID} ${USER_NAME}

# Allow sudo for user
echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker


# Set proper home directory
export HOME=$(eval echo ~$USER_NAME)

# Ensure HOME has proper permissions
chown ${USER_ID} ${HOME}

# Drop privs and preserve env
if [ -z "$1" ]
then
    # Get bash shell
    exec su -m ${USER_NAME} --session-command bash
else
    exec su -m ${USER_NAME} --session-command "$@"
fi
