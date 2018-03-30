# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node. based on evarga/jenkins-slave
FROM wrich04ca/jenkins-agent

USER root

# Install minimum required software
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list
RUN apt-get update

RUN apt-get -y install git
RUN apt-get -y install curl

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install curl, maven,
RUN apt-get update && apt-get install -y \
curl \
git \
openjdk-8-jdk \
sshpass \
&& rm -rf /var/lib/apt/lists/*

# Add node version 8 which should bring in npm, add maven and build essentials and required ssl certificates to contact maven central
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y nodejs expect build-essential maven ca-certificates-java && update-ca-certificates -f

RUN npm install npm --global

## Installs the libsecret library required by keytar
RUN apt-get install -y gnome-keyring libsecret-1-dev libsecret-tools

# Fingers crossed
RUN rm /etc/pam.d/login
# RUN rm /etc/pam.d/passwd
RUN rm /home/jenkins/.bashrc

COPY login /etc/pam.d/login
# COPY passwd /etc/pam.d/passwd
COPY .bashrc /home/jenkins/.bashrc

# ENV DISPLAY=localhost:0.0
# RUN secret-tool store --label="example" foo bar

CMD ["/usr/sbin/sshd", "-D"]
