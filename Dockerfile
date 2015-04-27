# TODO change this to debian
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

# Install apt packages
RUN apt-get install -y git curl ruby ruby-dev nginx mysql-server \
        make g++ libmysqlclient-dev libsqlite3-dev libxml2-dev libxslt-dev

# Install ruby pre-reqs
RUN gem install bundle

WORKDIR /home/docker

# Add build scripts
COPY Gemfile scripts/make-env.sh scripts/setup-component.sh credentials/ ./
COPY templates/ templates/
RUN chown -R docker.docker *; chmod u+x *.sh

USER docker
# Create directory to contain logs
ENV LOGS=logs
RUN mkdir $LOGS

RUN bundle install
RUN ./make-env.sh

ENV organisation='theodi'

# Initialise the components
RUN ./setup-component.sh signonotron2  signon          3000
RUN ./setup-component.sh static        static          4000
RUN ./setup-component.sh panopticon    panopticon      5000
RUN ./setup-component.sh publisher     publisher       6000
RUN ./setup-component.sh asset-manager asset-manager   7000
RUN ./setup-component.sh content_api   contentapi      8000
RUN ./setup-component.sh frontend-www  www             9000
RUN ./setup-component.sh rummager      search         10000

# Install runtime dependencies
RUN sudo apt-get install -y libaspell15 openjdk-6-jre node && \
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.deb && \
    sudo dpkg -i elasticsearch-0.90.7.deb && \
    rm elasticsearch-0.90.7.deb

# Copy over the setup scripts
COPY scripts/manage-services.sh scripts/prepare.sh scripts/db_setup.sql ./
RUN sudo chown -R docker.docker *; chmod u+x *.sh

# Define the port
EXPOSE 80 443
# Specify the command
# TODO Make this a more sensible startup component
CMD bash
