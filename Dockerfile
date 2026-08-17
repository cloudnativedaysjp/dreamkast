# syntax = docker/dockerfile:1.21

FROM node:22.22.0-slim AS node
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable
WORKDIR /app
COPY --link package.json yarn.lock .yarnrc.yml ./
# yarn berry のグローバルキャッシュをビルドキャッシュに載せる
RUN --mount=type=cache,target=/root/.yarn/berry/cache \
    yarn install --immutable

FROM public.ecr.aws/docker/library/ruby:4.0.5 AS fetch-lib
WORKDIR /app
COPY --link Gemfile* ./
RUN apt-get update && apt-get install -y shared-mime-info libmariadb3
RUN bundle install

FROM public.ecr.aws/docker/library/ruby:4.0.5 AS asset-compile
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
COPY --link --from=node /usr/local/bin/node /usr/local/bin/
COPY --link --from=node /usr/local/lib/node_modules/corepack /usr/local/lib/node_modules/corepack
# node ステージで取得済みの yarn を再利用する（ビルド時に再ダウンロードしない）
COPY --link --from=node /root/.cache/node/corepack /root/.cache/node/corepack
RUN ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable
WORKDIR /app
COPY --link postcss.config.js .
COPY --link tailwind.config.js .
COPY --link bin bin
COPY --link config config
COPY --link Rakefile Rakefile
COPY --link app app
# config/environments/production.rb が lib/logging を require するため lib も必要
COPY --link lib lib
COPY --link Gemfile* ./
COPY --link webpack.config.js webpack.config.js
COPY --link package.json yarn.lock .yarnrc.yml ./
COPY --link --from=node /app/node_modules /app/node_modules
COPY --link --from=fetch-lib /usr/local/bundle /usr/local/bundle
RUN apt-get update && apt-get install -y libvips42
ENV AWS_ACCESS_KEY_ID=''
ARG RAILS_ENV='production'
RUN --mount=type=cache,uid=1000,target=/app/tmp/cache SECRET_KEY_BASE=hoge RAILS_ENV=${RAILS_ENV} DREAMKAST_NAMESPACE=dreamkast DB_ADAPTER=nulldb bin/rails assets:precompile

FROM public.ecr.aws/docker/library/ruby:4.0.5-slim

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
COPY --link --from=node /usr/local/bin/node /usr/local/bin/
COPY --link --from=node /usr/local/lib/node_modules/corepack /usr/local/lib/node_modules/corepack
COPY --link --from=node /root/.cache/node/corepack /root/.cache/node/corepack
RUN ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable
ARG RAILS_ENV='production'
ENV RAILS_ENV=${RAILS_ENV}, RAILS_LOG_TO_STDOUT=ON, RAILS_SERVE_STATIC_FILES=enabled
WORKDIR /app
COPY --link --from=node /app/node_modules /app/node_modules
COPY --link --from=fetch-lib /usr/local/bundle /usr/local/bundle
RUN apt-get update && apt-get -y install wget ca-certificates libmariadb3 libvips42 chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV CHROME_BIN=/usr/bin/chromium
COPY --link . .
COPY --link --from=asset-compile /app/public /app/public
# RDS 接続の TLS 検証(verify_identity)用に、グローバル CA バンドルをビルド時に取得する
RUN mkdir -p /app/config/certs && \
    wget -q -O /app/config/certs/rds-global-bundle.pem \
      https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
EXPOSE 3000
ENV RUBY_YJIT_ENABLE=1
ENTRYPOINT ["./entrypoint.sh"]
