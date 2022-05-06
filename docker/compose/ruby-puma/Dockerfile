FROM alpine:3.15

USER root
RUN apk add curl
RUN gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN rvm install 2.5.3

# RUN apk add php7.4-memcached imagemagick
USER amplify
