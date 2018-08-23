# This Dockerfile is used to build an image capable of running the npm keytar node module
# IT MUST BE RUN AS PRIVELEGED IN ORDER TO PROPERLY OPERATE
FROM ahumanfromca/jenkins-npm-agent

# Installs the libsecret library required by keytar
RUN apt-get update && apt-get install -y gnome-keyring libsecret-1-dev

ARG tempLocation=/tmp/jenkins-npm-keytar
RUN mkdir ${tempLocation}

# Copy the PAM configuration options to allow auto unlocking of the gnome keyring
COPY pam.config ${tempLocation}/pam.config

# Enable unlocking for ssh
RUN cat ${tempLocation}/pam.config>>/etc/pam.d/sshd

# Enable unlocking for regular login
RUN cat ${tempLocation}/pam.config>>/etc/pam.d/login

# Copy the profile script that needs to run to allow autostart of the dbus session without a display
COPY dbus_start ${tempLocation}/dbus_start

# Enable dbus for ssh and most other native shells
ARG profileLoc=/etc/profile.d/dbus_start.sh
RUN touch ${profileLoc} \
    && echo '#!/bin/sh'>>${profileLoc} \
    && cat ${tempLocation}/dbus_start>>${profileLoc}

# Enable for all bash profiles
ARG globalBashrc=/etc/bash.bashrc
RUN touch ${globalBashrc} \
    && cat ${tempLocation}/dbus_start>>${globalBashrc}

# Cleanup any temp files we have created
RUN rm -rdf ${tempLocation}

CMD ["/usr/sbin/sshd", "-D"]
