FROM ruby:1.9.3
MAINTAINER giles@dringtech.com

COPY src/ ./

VOLUME /usr/local/bundle
ENTRYPOINT ["/usr/local/bin/rake"]
CMD ["default"]
