# This Dockerfile is used to build an image capable of running the npm keytar node module
# It must be given the capability of IPC_LOCK or be run in privilaged mode to properly operate
FROM zfernand0/jenkins-nvm-agent

USER root

# Installs the libsecret library required by keytar
RUN apt-get update && apt-get install -y gnome-keyring libsecret-1-dev

ARG tempDir=/tmp/jenkins-npm-keytar
ARG sshEnv=/etc/profile.d/dbus_start.sh
ARG bashEnv=/etc/bash.bashrc

ARG loginFile=pam.d.config

RUN mkdir ${tempDir}

# Copy the PAM configuration options to allow auto unlocking of the gnome keyring
COPY ${loginFile} ${tempDir}/${loginFile}

# Enable unlocking for ssh
RUN cat ${tempDir}/${loginFile}>>/etc/pam.d/sshd

# Enable unlocking for regular login
RUN cat ${tempDir}/${loginFile}>>/etc/pam.d/login

# Copy the profile script
COPY dbus_start ${tempDir}/dbus_start

# Enable dbus for ssh and most other native shells (interactive)
RUN touch ${sshEnv} \
    && echo '#!/bin/sh'>>${sshEnv} \
    && cat ${tempDir}/dbus_start>>${sshEnv}

# Enable for all bash profiles
# Add the dbus launch before exiting when not running interactively
RUN sed -i -e "/# If not running interactively, don't do anything/r ${tempDir}/dbus_start" -e //N ${bashEnv}

# Cleanup any temp files we have created
RUN rm -rdf ${tempDir}

# Exec ssh
CMD ["/usr/sbin/sshd", "-D"]
