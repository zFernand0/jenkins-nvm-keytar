# jenkins-npm-keytar

Jenkins build agent with the ability to install the npm keytar package for credential management. Builds on [jenkins-npm-agent](https://github.com/AHumanFromCA/jenkins-npm-agent)

**NOTE:** This image will need to run privileged and the gnome-keyring must be manually unlocked prior to using keytar to avoid dbus-launch errors. If someone could figure out how to do this in an unprivileged container, that would be great.  

## Running in Bash

To access keyring functions in bash mode simply execute the following terminal command:

```sh
echo 'jenkins' | gnome-keyring-daemon --unlock
```

## Running in a Jenkins Pipeline

This section will provide you with some configuration and background information to help you out in your pipeline.

### Overview

To execute commands from Jenkins that use keytar/libsecret functionality, you will need to create a basic shell script.

```sh
#!/usr/bin/env bash

# Unlock the keyring
echo 'jenkins' | gnome-keyring-daemon --unlock

# Your commands here
```

This shell script performs the following actions:

1. Unlocks the gnome-keyring.
2. Runs your commands with the keyring unlocked.

In your Jenkinsfile, you will want to have a line like this in your step:

```groovy
sh "chmod +x $TEST_SCRIPT && dbus-launch $TEST_SCRIPT"
```

This command is used to run the tests. `$TEST_SCRIPT` is a string that points to the location of the shell script you created. The next section talks about that command in further detail.

At a high level, this command performs the following actions:

1. Gives execute permissions to the shell script.
2. Executes the shell script in a D-Bus session.

### What is the gnome-keyring?

The gnome-keyring is where credentials are ultimately stored by keytar/libsecret.

#### Why Unlock the Keyring?

Until the keyring is unlocked, nothing can have access to it. This is normally done automatically when in a Linux GUI environment but the agent is not a GUI environment. Therefore, the keyring must be unlocked before keytar can perform credential access.

### What Does `dbus-launch` Do?

***DISCLAIMER:** This is not intended to be a full deep dive into D-Bus. This is only meant as a high level overview. If you want more info, you will need to research on your own.*

D-Bus is essentially a message service bus that allows applications running within the same D-Bus session to communicate with eachother. The underlying libsecret library adheres to the SecretService standard, which ties into D-Bus.

keytar/libsecret cannot operate properly without a proper D-Bus session.

There is no D-Bus session available when the Jenkins agent is spawned, so one needs to be started. Without starting a D-Bus session, it is impossible to unlock the keyring and allow keytar to access it (there is no mechanism for the two applications to communicate). Thus, a D-Bus session must be created and both the keyring unlock and the test execution must be run witin this session. `dbus-launch` accomplishes this, but only for the lifetime of the executed shell script.

#### Why is the Shell Script Required?

It comes down to this:

`dbus-launch A && B` is the same as `dbus-launch A` && `b`. There may be a way that both could be executed under the same command, but that would pose a problem for readiblity.

### Final Note

After we performed the steps above, we aso needed to perform the following additional step:

The docker container spawned for the image must be running in privileged mode. If not, you will see a message like the following when the shell script tries to unlock the keyring:

```
gnome-keyring-daemon: Operation not permitted
```

On Jenkins, this requires you to check the `Run container privileged` container setting for the agent. (Only admins of Jenkins are able to check this setting.)

## Running in SSH

Like the Jenkins Pipeline, a DBus session must be spawned through ssh before unlocking the keyring.