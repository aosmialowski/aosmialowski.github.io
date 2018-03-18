FROM golang:1.10-alpine
MAINTAINER Andrzej Ośmiałowski <me@osmialowski.net>

EXPOSE 1313

WORKDIR /site

ENV HUGO_VERSION=0.37.1
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp
RUN tar -xf /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/hugo

ARG APP_URL

CMD ["/bin/sh", "-c", "/usr/local/bin/hugo --watch=true --buildDrafts --buildFuture --bind=0.0.0.0 --baseURL=${APP_URL} server /site"]