#!/usr/bin/env bash

# Make sure we're running in the docker home directory
pushd ~docker

# Capture local variables
theirname=$1
ourname=$2
port=$3

# Get or refresh the code
if [ -d "$DIRECTORY" ]; then
  pushd ${ourname}
  git pull origin master
  popd
else
  # Control will enter here if $DIRECTORY exists.
  git clone https://github.com/${organisation}/${theirname}.git ${ourname}
fi

# Change to repo directory
pushd ${2}

# Install ruby dependencies
bundle install

# Link generated environment
rm -f .env && ln -sf ../env .env

# Generate foreman option file, which will be read when starting up
if [ -f Procfile ]; then
    cat > .foreman <<OPTIONS
app: ${ourname}
port: ${port}
user: docker
OPTIONS
fi

# Make vhost file from template
servername=${ourname}
domain=${GOVUK_APP_DOMAIN}
template_file=~docker/templates/vhost
eval "echo \"$(< ${template_file})\"" > vhost

# Change back to the docker home directory
popd

# Add the nginx config files
sudo rm -f /etc/nginx/sites-enabled/${ourname}
sudo ln -sf ${PWD}/${ourname}/vhost /etc/nginx/sites-enabled/${ourname}

# Change back to the original directory
popd
