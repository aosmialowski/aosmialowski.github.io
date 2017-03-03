FROM golang:1.8
MAINTAINER Andrzej Ośmiałowski <me@osmialowski.net>

WORKDIR /site

RUN curl -OL https://github.com/spf13/hugo/releases/download/v0.19/hugo_0.19_Linux-64bit.tar.gz \
    && tar --strip=1 -zxvf hugo_0.19_Linux-64bit.tar.gz -C /tmp \
    && mv /tmp/hugo_0.19_linux_amd64 /usr/local/bin/hugo

ARG APP_UID=1000
ARG APP_URL=http://localhost:1313

RUN useradd -m hugo
RUN usermod -u $APP_UID hugo
USER hugo

CMD ["/bin/sh", "-c", "/usr/local/bin/hugo --watch=true --buildDrafts --buildFuture --bind=0.0.0.0 --baseURL=${APP_URL} server /site"]
