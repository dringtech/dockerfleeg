# Dockerfleeg

This is an dockerized version the ODI [Quirkafleeg][QF], which is largely a
gigantic Ruby script.

[QF]: https://github.com/theodi/quirkafleeg "Link to the ODI Quirkafleeg repo"

## Prereqs

1. Working docker install
2. `node`, if you want to use the npm scripts

For Mac OS X, use [`boot2docker`][BD], and make sure you run \
`eval $(boot2docker shellinit)` before attempting to use docker.

[BD]: http://boot2docker.io/ "Link to Boot2Docker homepage"

Again, for Mac OS X, I strongly recommend [Homebrew][HB], which allows this

    brew install boot2docker node

[HB]: http://brew.sh/ "Link to Homebrew homepage"

## Preparing the environment

Run `./prepare.sh` script


if running in `boot2docker`, make sure you do this:

    VBoxManage modifyvm "boot2docker-vm" natpf1 "tcp-port80,tcp,,80,,80";

(or if already running...)

    VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port80,tcp,,80,,80";

Run the image

    docker run -p 80:80 -ti gilesdring/dockerfleeg bash


# DNS setup

http://passingcuriosity.com/2013/dnsmasq-dev-osx/
