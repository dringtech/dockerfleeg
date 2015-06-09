function create_vhost {
    servername=$1
    domain=${GOVUK_APP_DOMAIN}
    port=$2
    template_file=vhost.template

    eval "echo \"$(< ${template_file})\"" > /etc/nginx/sites-enabled/${servername}
}

mkdir /etc/nginx/sites-enabled
create_vhost asset-manager 8000
create_vhost contentapi 8000
create_vhost panopticon 8000
create_vhost publisher 8000
create_vhost search 8000
create_vhost signon 8000
create_vhost static 8000
create_vhost www 8000
