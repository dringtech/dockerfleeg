#!/usr/bin/env bash

OAUTH_FILE=~docker/oauthcreds

function format_env_variable {
    awk 'BEGIN {FS="="} {sub(/-/,"_"); gsub(/ +/, ""); print toupper($1) "=" $2}'
}

function get_bearer_token {
    awk '/^Access token:/ {print $3}'
}

function generate_app_key {
    local app=$1
    local description=$2
    local domain=${GOVUK_APP_DOMAIN}

    echo "Generating application keys for ${app}"
    bundle exec rake applications:create name=${app} \
        description="${description}" home_uri="http://${app}.${domain}" \
        redirect_uri="http://${app}.${domain}/auth/gds/callback" \
        supported_permissions=signin,access_unpublished | \
        grep ^config | sed -e "s/^config\./${app}_/" -e "s/'//g" | \
        format_env_variable \
        >> ${OAUTH_FILE}
}

function generate_asset_manager_bearer_token {
    local app=$1

    echo "Generating bearer token for ${app}"
    token=$(bundle exec rake \
        api_clients:create[${app},"${app}@example.com",asset-manager,signin] |\
        get_bearer_token)
    cat - << BEARER_TOKENS | format_env_variable >> ${OAUTH_FILE}
${app}_asset_manager_bearer_token=${token}
${app}_api_client_bearer_token=${token}
BEARER_TOKENS
}

function generate_content_api_bearer_tokens {
    local domain=${GOVUK_APP_DOMAIN}

    echo "Generating content-api bearer tokens for frontends"
    bundle exec rake applications:create name=frontends \
        description="Front end apps" home_uri="http://frontends.${domain}" \
        redirect_uri="http://frontends.${domain}/auth/gds/callback" \
        supported_permissions=access_unpublished
        token=$(bundle exec rake \
            api_clients:create[frontends,"frontends@example.com",contentapi,access_unpublished] |\
            get_bearer_token)
    echo QUIRKAFLEEG_FRONTEND_CONTENTAPI_BEARER_TOKEN=${token} >> ${OAUTH_FILE}
}

function create_user {
    local apps=panopticon,publisher,asset-manager,contentapi
    local user=$1
    local email=$2

    echo "Creating user '${user}'"
    bundle exec rake users:create name=${user} email=${email} \
        applications=${apps}
}

pushd ~docker  > /dev/null

. ./env

# Create signonotron user
echo "Initialising signonotron user"
sudo mysql -v < db_setup.sql

# Setup signon
pushd signon   > /dev/null

echo "Configuring signon database"
bundle exec rake db:create
bundle exec rake db:migrate

bundle exec ./script/make_oauth_work_in_dev

generate_app_key panopticon    "metadata management"
generate_app_key publisher     "content editing"
generate_app_key asset-manager "media uploading"
generate_app_key contentapi    "internal API for content access"

generate_asset_manager_bearer_token publisher
generate_asset_manager_bearer_token contentapi

generate_content_api_bearer_tokens

create_user alice alice@example.com
create_user bob bob@example.com

popd  > /dev/null

# Setup search
pushd search > /dev/null

echo "Creating indices for rummager"
RUMMAGER_INDEX=all bundle exec rake rummager:migrate_index

popd > /dev/null

# Setup panopticon
pushd panopticon > /dev/null

echo "Setting up panopticon"
bundle exec rake db:seed

popd > /dev/null

popd > /dev/null
