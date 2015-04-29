# TODO change this to debian
FROM ruby:1.9.3
MAINTAINER Giles Dring <gilesdring@gmail.com>

# Set location for external gem cache - stored on a container volume
ENV GEM_HOME=/ruby_gems/1.9.3
ENV PATH=${GEM_HOME}/bin:$PATH

RUN apt-get update -qq && apt-get -y autoremove && apt-get install -y sudo build-essential
RUN apt-get install -y libmysqlclient-dev libsqlite3-dev libxml2-dev libxslt-dev
RUN apt-get install -y nginx mysql-client node libaspell15

# Add docker user and change set working directory
ENV SUDOFILE=/etc/sudoers.d/docker-user
RUN useradd -m docker && echo "docker ALL=(ALL) NOPASSWD:ALL" > $SUDOFILE && chmod 0440 $SUDOFILE && chown root.root $SUDOFILE
WORKDIR /home/docker

# Add build scripts
COPY Gemfile app.lst scripts/ credentials/ ./
COPY templates/ templates/
RUN chown -R docker.docker *; chmod u+x *.sh manage

# Change to docker user
USER docker

ENV organisation='theodi' 

RUN ./make-env.sh

# Clone repositories
RUN while read -r ourname theirname port; do \
        git clone https://github.com/${organisation}/${theirname}.git ${ourname}; \
    done < app.lst

EXPOSE 80 443
CMD bash
