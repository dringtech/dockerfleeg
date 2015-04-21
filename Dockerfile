FROM ubuntu-upstart
MAINTAINER Giles Dring <gilesdring@gmail.com>

# Add docker user and add to new sudoers file
ENV SUDOFILE=/etc/sudoers.d/docker-user
RUN useradd -m docker && echo "docker ALL=(ALL) NOPASSWD:ALL" > $SUDOFILE && chmod 0440 $SUDOFILE && chown root.root $SUDOFILE

# Install MongoDB
# Import MongoDB public GPG key AND create a MongoDB list file
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
# Upate the sources and install
RUN apt-get update && apt-get install -y mongodb
# Create the MongoDB data directory
RUN mkdir -p /data/db

# Setup users and install packages
# RUN dpkg-divert --local --rename --add /sbin/initctl && \
#     ln -s /bin/true /sbin/initctl && \
RUN apt-get install -y git curl ruby ruby-dev nginx mysql-server \
        make g++ libmysqlclient-dev libsqlite3-dev libxml2-dev libxslt-dev

WORKDIR /home/docker

# Add startup scripts for background services: Nginx, MySQL and MongoDB
ADD scripts/ .
RUN chown docker.docker *
RUN chmod u+x *.sh

USER docker
# Create directory to contain logs
ENV LOGS=logs
RUN mkdir $LOGS

ENV organisation='theodi'

# Install build pre-reqs
RUN gem install bundle foreman

# SETUP signon
RUN git clone https://github.com/${organisation}/signonotron2.git signon
WORKDIR signon
RUN bundle

# Do we even need to get this anymore?
# TODO remove dependency on setup.rb script
# RUN git clone https://github.com/gilesdring/quirkafleeg.git
# WORKDIR quirkafleeg
# RUN ./setup.rb
