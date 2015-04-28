#!/usr/bin/env bash

DOMAIN="dev"

OUTFILE=./env

cat - <<-EOF > ${OUTFILE}
GOVUK_APP_DOMAIN=${DOMAIN}
DEV_DOMAIN=${DOMAIN}
GDS_SSO_STRATEGY=real
STATIC_DEV=http://static.${DOMAIN}
GOVUK_ASSET_ROOT=static.${DOMAIN}
PANOPTICON_USER='api'
PANOPTICON_PASSWORD='mysuperawesomepassword'
CONTENTAPI_DEFAULT_ROLE=odi
RUMMAGER_HOST=http://search.dev

# Redis configuration variables
REDIS_PROVIDER=REDIS_PORT_6379_TCP
QUIRKAFLEEG_SIGNON_REDIS_HOST=${REDIS_PORT_6379_TCP_ADDR}
QUIRKAFLEEG_SIGNON_REDIS_PASSWORD=
QUIRKAFLEEG_RUMMAGER_REDIS_URL=${REDIS_PORT_6379_TCP}
EOF

function import_creds {
    local cred_file="$1"
    [ -f ${cred_file} ] && cat ${cred_file} >> ${OUTFILE}
    return 0
}

for f in 'rackspacecreds' 'mandrillcreds' 'oauthcreds' 'juviacreds'
do
    import_creds $f
done
