#!/usr/bin/env bash

BASE_DIR=~

pushd ${BASE_DIR} > /dev/null

# Install bundle
sudo gem install bundle

# Install dependencies
bundle install

# Patch the search Gemfile
sed -i "/ffi-aspell/s/0.0.3/1.0.2/" search/Gemfile

while read -r ourname theirname port
do
    ./prepare-component.sh ${theirname} ${ourname} ${port}
done < app.lst

# Setup redis
bash ${BASE_DIR}/templates/redis.yml > signon/config/redis.yml
bash ${BASE_DIR}/templates/redis.yml > publisher/config/redis.yml

# Setup mysql
# TODO Fix this to be a proper template
sed -i "/^development:/a \  host: ${MYSQL_PORT_3306_TCP_ADDR}" signon/config/database.yml
sed -i "/^test:/a \  host: ${MYSQL_PORT_3306_TCP_ADDR}" signon/config/database.yml

# Setup mongo hosts in mongoid.yml files
sed -i "s/host: *localhost/host: ${MONGO_PORT_27017_TCP_ADDR}/g" \
    panopticon/config/mongoid.yml \
    contentapi/mongoid.yml \
    .bundler/ruby/1.9.1/odi_content_models-d238a8736a05/config/mongoid.yml \
    .bundler/ruby/1.9.1/odi_content_models-c74507b76c2e/config/mongoid.yml \
    asset-manager/config/mongoid.yml \
    publisher/config/mongoid.yml

# Setup elasticsearch host
sed -i "s/base_uri\: *.*/base_uri\: \"http:\/\/${ELASTICSEARCH_PORT_9200_TCP_ADDR}:${ELASTICSEARCH_PORT_9200_TCP_PORT}\"/" search/elasticsearch.yml

# Create procfile
echo web: sudo nginx -g \"daemon off\;\" > Procfile
while read -r app theirname port; do
    cat ${app}/Procfile | sed -e "s/\$PORT/${port}/" -e "/^.*:/s/^/${app}_/" -e "s/:/: cd ${app} \&\&/"
    echo
done < app.lst >> Procfile

function extract_app_keys {
    awk '
BEGIN { FS="\t" }
NR>1 {
    name = toupper($1)
    sub("-","_",name)
    print name "_OAUTH_ID=" $2
    print name "_OAUTH_SECRET=" $3
}'
}

function extract_bearer_tokens {
    awk '
BEGIN { FS="\t" }
NR>1 {
    name = toupper($1)
    sub("-","_",name)
    print name "_ASSET_MANAGER_BEARER_TOKEN=" $2
    print name "_API_CLIENT_BEARER_TOKEN=" $2
}'
}

function extract_frontend_bearer_tokens {
    awk '
BEGIN { FS="\t" }
NR>1 {
    print name "QUIRKAFLEEG_FRONTEND_CONTENTAPI_BEARER_TOKEN=" $2
}'
}

function run_mysql_command {
    mysql -u 'root' -h ${MYSQL_PORT_3306_TCP_ADDR} \
        --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}
}

OAUTH_FILE=~/oauthcreds

echo > ${OAUTH_FILE}

run_mysql_command <<EOF | extract_app_keys >> ${OAUTH_FILE}
USE signonotron2_development
SELECT name, uid, secret FROM oauth_applications
    WHERE name IN ('panopticon', 'publisher', 'asset-manager', 'contentapi');
EOF

run_mysql_command <<EOF | extract_bearer_tokens >> ${OAUTH_FILE}
USE signonotron2_development
SELECT
    u.name, t.token
FROM
    users u,
    permissions p,
    oauth_access_tokens t
WHERE
    p.id = t.resource_owner_id
AND
    u.id = p.user_id
AND
    u.name in ('publisher', 'contentapi');
EOF

# Get frontend BEARER
run_mysql_command <<EOF | extract_frontend_bearer_tokens >> ${OAUTH_FILE}
USE signonotron2_development
SELECT
    u.name, t.token
FROM
    users u,
    permissions p,
    oauth_access_tokens t
WHERE
    p.id = t.resource_owner_id
AND
    u.id = p.user_id
AND
    u.name in ('frontends');
EOF

# List users
run_mysql_command <<EOF
USE signonotron2_development;
SELECT email, invitation_token FROM users;
EOF

./make-env.sh

popd > /dev/null
