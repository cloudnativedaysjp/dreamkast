# syntax = docker/dockerfile:1.12

FROM node:18.20.5-slim AS node
WORKDIR /app
COPY --link package.json yarn.lock ./
RUN --mount=type=cache,uid=1000,target=/app/.cache/node_modules \
    yarn install --modules-folder .cache/node_modules && \
    cp -ar .cache/node_modules node_modules

FROM public.ecr.aws/docker/library/ruby:3.3.6 AS fetch-lib
WORKDIR /app
COPY --link Gemfile* ./
RUN apt-get update && apt-get install -y shared-mime-info libmariadb3
RUN bundle install

FROM public.ecr.aws/docker/library/ruby:3.3.6 AS asset-compile
ENV YARN_VERSION=1.22.22
COPY --link --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --link --from=node /usr/local/bin/node /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
WORKDIR /app
COPY --link postcss.config.js .
COPY --link bin bin
COPY --link config config
COPY --link Rakefile Rakefile
COPY --link app app
COPY --link Gemfile* ./
COPY --link webpack.config.js webpack.config.js
COPY --link package.json yarn.lock ./
COPY --link --from=node /app/node_modules /app/node_modules
COPY --link --from=fetch-lib /usr/local/bundle /usr/local/bundle
RUN apt-get update && apt-get install -y libvips42
ENV AWS_ACCESS_KEY_ID=''
ARG RAILS_ENV='production'
RUN --mount=type=cache,uid=1000,target=/app/tmp/cache SECRET_KEY_BASE=hoge RAILS_ENV=${RAILS_ENV} DB_ADAPTER=nulldb bin/rails assets:precompile

FROM public.ecr.aws/docker/library/ruby:3.3.6-slim

ENV YARN_VERSION=1.22.22
COPY --link --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --link --from=node /usr/local/bin/node /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
ARG RAILS_ENV='production'
ENV RAILS_ENV=${RAILS_ENV}, RAILS_LOG_TO_STDOUT=ON, RAILS_SERVE_STATIC_FILES=enabled
WORKDIR /app
COPY --link --from=node /app/node_modules /app/node_modules
COPY --link --from=fetch-lib /usr/local/bundle /usr/local/bundle
RUN apt-get update && apt-get -y install wget libmariadb3 libvips42 \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -y ./google-chrome-stable_current_amd64.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --link . .
COPY --link --from=asset-compile /app/public /app/public
EXPOSE 3000
ENV RUBY_YJIT_ENABLE=1
ENTRYPOINT ["./entrypoint.sh"]
