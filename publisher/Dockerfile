FROM ruby:1.9.3
MAINTAINER Giles Dring <giles@dringtech.com>
# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential
ENV COMPONENT=publisher
RUN mkdir /${COMPONENT}
WORKDIR /${COMPONENT}
# Need to add Gemfile and Gemfile.lock to ensure that gems are installed correctly
ADD repo/Gemfile /${COMPONENT}/Gemfile
ADD repo/Gemfile.lock /${COMPONENT}/Gemfile.lock
RUN bundle config mirror.https://rubygems.org http://rubygems.org && \
    bundle install
ADD repo /${COMPONENT}
ENV DOMAIN=localdev PORT=8000
ENV GOVUK_APP_DOMAIN=${DOMAIN} DEV_DOMAIN=${DOMAIN} \
    GDS_SSO_STRATEGY=real STATIC_DEV=http://static.${DOMAIN} \
    GOVUK_ASSET_ROOT=static.${DOMAIN} \
    PANOPTICON_USER='api' PANOPTICON_PASSWORD='mysuperawesomepassword' \
    CONTENTAPI_DEFAULT_ROLE=odi RUMMAGER_HOST=http://search.${DOMAIN}
EXPOSE ${PORT}
ENTRYPOINT ["bundle", "exec"]
CMD ["foreman", "start"]
