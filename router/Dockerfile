# Set nginx base image
FROM nginx

# File Author / Maintainer
MAINTAINER Giles Dring <giles@dringtech.com>

WORKDIR /tmp
ADD setup.sh vhost.template ./
ADD nginx.conf /etc/nginx/nginx.conf
ENV GOVUK_APP_DOMAIN=localdev
RUN bash setup.sh
