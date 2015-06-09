# dockerfleeg
Dockerized version of the ODI Quirkafleeg

## Dependencies

1. Working installation of `docker` and `docker-compose`. If on Mac OS X, with
   a working [`homebrew`](http://brew.sh) setup,
   `brew install docker docker-compose` will have you up and running quickest.
2. If running on Mac OS X, a working instance of `boot2docker`. I found
   `docker-machine` to be somewhat flaky.
3. A way of resolving your development domain to the host running the docker
   containers. I use a local `dnsmasq` with a resolver file pointing
   `.localdev` to the local `boot2docker` shared network address as a DNS server.

## Setup

### Get the code

    git clone git@github.com:dringtech/dockerfleeg.git <path>
    cd <path>

`<path>` is the root directory of the repository.

### Setup the submodules...

    git submodule init
    git submodule update

### Fix the hosts and paths

There are quite a number of localhost or undefined hosts in the development
config. These all need fixing (pending me sorting out a different config).
Just for the moment, these are stored in patch files, which can be applied by
running the command

    ./patch.sh

from the root directory of the main repository. This will work on Mac OS X
and *nix environments. Windows folk, I'm afraid you're on your own!

### Build the docker images

Change to the root directory of the repository if you're not already there.
You will need to ensure that your docker environment variables are set if
needed. Under boot2docker, run the following

    eval $(boot2docker shellinit)

Then build the images with the following command.

    docker-compose build

It will help to have a fast broadband connection and a good book (or something
else to do) at this point, as it takes aaaaaaaages.

### Setup the signon databases

    docker-compose run signon bash ./init.sh
    docker-compose run -e RUMMAGER_INDEX=all search rake rummager:migrate_index
    docker-compose run panopticon rake db:seed

### Restoring a content dump

Store unzipped backup in the somewhere useful. Start the MongoDB instance
using

    docker-compose up mongo

Once this has started, issue the following commands:

    mongorestore --drop -d govuk_content_development <path>/govuk_content_publisher -h <host>

The `host` is the IP address of the docker host.
