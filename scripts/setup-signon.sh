#!/usr/bin/env bash

pushd ~docker

pushd signon

bundle exec rake db:create
bundle exec rake db:migrate

bundle exec ./script/make_oauth_work_in_dev

function generate_app_key {
    local app=$1
    local description=$2
    local domain=${GOVUK_APP_DOMAIN}

    echo "Generating application keys for ${app}"
    bundle exec rake applications:create name=${app} \
        description="${description}" home_uri="http://${app}.${domain}" \
        redirect_uri="http://${app}.${domain}/auth/gds/callback" \
        supported_permissions=signin,access_unpublished
}

generate_app_key panopticon    "metadata management"
generate_app_key publisher     "content editing"
generate_app_key asset-manager "media uploading"
generate_app_key contentapi    "internal API for content access"

popd
