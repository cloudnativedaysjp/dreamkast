# syntax = docker/dockerfile:experimental

FROM node:14.17.0-slim as node
WORKDIR /app
COPY package.json yarn.lock ./
RUN --mount=type=cache,uid=1000,target=/app/.cache/node_modules \
    yarn install --modules-folder .cache/node_modules && \
    cp -ar .cache/node_modules node_modules

FROM ruby:2.7.2 as fetch-lib
WORKDIR /app
COPY Gemfile* ./
RUN apt-get update && apt-get install shared-mime-info
RUN bundle install

FROM ruby:2.7.2 as asset-compile
ENV YARN_VERSION 1.22.4
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
ENV AWS_ACCESS_KEY_ID=''
RUN --mount=type=cache,uid=1000,target=/app/tmp/cache SECRET_KEY_BASE=hoge RAILS_ENV=production DB_ADAPTER=nulldb bin/rails assets:precompile

FROM ruby:2.7.2-slim

ENV YARN_VERSION 1.22.4
COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
ENV RAILS_ENV=production, RAILS_LOG_TO_STDOUT=ON, RAILS_SERVE_STATIC_FILES=enabled
WORKDIR /app
COPY --from=node /app/node_modules /app/node_modules
COPY --from=fetch-lib /usr/local/bundle /usr/local/bundle
COPY --from=fetch-lib /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/x86_64-linux-gnu/libmariadb.so.3
COPY . .
COPY --from=asset-compile /app/public /app/public
EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
