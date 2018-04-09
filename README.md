# jenkins-npm-keytar

Jenkins build agent with the ability to install the npm keytar package

**NOTE:** This image will need to run privileged and the gnome-keyring must be manually unlocked prior to using keytar to avoid dbus-launch errors. If someone could figure out how to do this in an unprivileged container, that would be great.  
