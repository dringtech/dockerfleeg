#!/usr/bin/env bash

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

OAUTH_FILE=oauthcreds

run_mysql_command <<EOF | extract_app_keys
USE signonotron2_development
SELECT name, uid, secret FROM oauth_applications
    WHERE name IN ('panopticon', 'publisher', 'asset-manager', 'contentapi');
EOF

run_mysql_command <<EOF | extract_bearer_tokens
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
run_mysql_command <<EOF | extract_frontend_bearer_tokens
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
SELECT email, invitation_token FROM users WHERE invitation_token IS NOT NULL;
EOF

