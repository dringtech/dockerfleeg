#!/usr/bin/env bash

DOMAIN="dev"

OUTFILE=./env

echo "GOVUK_APP_DOMAIN=${DOMAIN}" > ${OUTFILE}
echo "DEV_DOMAIN=${DOMAIN}" >> ${OUTFILE}
echo "GDS_SSO_STRATEGY=real" >> ${OUTFILE}
echo "STATIC_DEV=http://static.${DOMAIN}" >> ${OUTFILE}
echo "GOVUK_ASSET_ROOT=static.${DOMAIN}" >> ${OUTFILE}
echo "PANOPTICON_USER='api'" >> ${OUTFILE}
echo "PANOPTICON_PASSWORD='mysuperawesomepassword'" >> ${OUTFILE}
echo "CONTENTAPI_DEFAULT_ROLE=odi" >> ${OUTFILE}
echo "RUMMAGER_HOST=http://search.dev" >> ${OUTFILE}

function import_creds {
    local cred_file="$1"
    [ -f ${cred_file} ] && cat ${cred_file} >> ${OUTFILE}
    return 0
}

for f in 'rackspacecreds' 'mandrillcreds' 'oauthcreds' 'juviacreds'
do
    import_creds $f
done
