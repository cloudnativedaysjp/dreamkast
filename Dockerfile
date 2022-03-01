# syntax = docker/dockerfile:experimental

FROM ruby:3.0.2-slim as build-vips

RUN apt-get update && apt install -y wget build-essential pkg-config libglib2.0-dev libexpat1-dev
RUN wget https://github.com/libvips/libvips/releases/download/v8.12.2/vips-8.12.2.tar.gz \
    && tar zxf vips-8.12.2.tar.gz \
    && cd vips-8.12.2 \
    && ./configure \
    && make -j4

FROM node:16.13.1-slim as node
WORKDIR /app
COPY package.json yarn.lock ./
RUN --mount=type=cache,uid=1000,target=/app/.cache/node_modules \
    yarn install --modules-folder .cache/node_modules && \
    cp -ar .cache/node_modules node_modules

FROM ruby:3.0.2 as fetch-lib
WORKDIR /app
COPY Gemfile* ./
RUN apt-get update && apt-get install shared-mime-info libmariadb3
RUN bundle install

FROM ruby:3.0.2 as asset-compile
ENV YARN_VERSION 1.22.15
COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
WORKDIR /app
COPY postcss.config.js .
COPY bin bin
COPY config config
COPY Rakefile Rakefile
COPY app app
COPY Gemfile* ./
COPY package.json yarn.lock ./
COPY --from=node /app/node_modules /app/node_modules
COPY --from=fetch-lib /usr/local/bundle /usr/local/bundle
COPY --from=build-vips /vips-8.12.2 /vips-8.12.2
RUN cd /vips-8.12.2 && make install
ENV AWS_ACCESS_KEY_ID=''
RUN --mount=type=cache,uid=1000,target=/app/tmp/cache SECRET_KEY_BASE=hoge RAILS_ENV=production DB_ADAPTER=nulldb bin/rails assets:precompile

FROM ruby:3.0.2-slim

ENV YARN_VERSION 1.22.15
COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
ENV RAILS_ENV=production, RAILS_LOG_TO_STDOUT=ON, RAILS_SERVE_STATIC_FILES=enabled
WORKDIR /app
COPY --from=node /app/node_modules /app/node_modules
COPY --from=fetch-lib /usr/local/bundle /usr/local/bundle
COPY --from=build-vips /vips-8.12.2 /vips-8.12.2
RUN apt-get update && apt-get -y install libglib2.0-dev libexpat1-dev libmariadb3 build-essential \
    && cd /vips-8.12.2 && make install && apt-get purge -y build-essential libglib2.0-dev libexpat1-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY . .
COPY --from=asset-compile /app/public /app/public
EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
