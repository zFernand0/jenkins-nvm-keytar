# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node. based on evarga/jenkins-slave
FROM evarga/jenkins-slave

ARG DEBIAN_FRONTEND=noninteractive

# Make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update -q

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
RUN apt-get install -y nodejs build-essential maven ca-certificates-java && update-ca-certificates -f

## Installs the libsecret library required by keytar
RUN apt-get install -y libsecret-1-dev

# add jenkins to list of sudo
RUN usermod -aG sudo jenkins

# Using custome sudoers file to allow jenkins to issue sudo without password
RUN rm /etc/sudoers
COPY config/sudoers /etc/sudoers

CMD ["/usr/sbin/sshd", "-D"]
