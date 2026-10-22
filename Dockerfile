# syntax = docker/dockerfile:1.21

FROM node:22.23.3-slim AS node
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable
WORKDIR /app
COPY --link package.json yarn.lock .yarnrc.yml ./
# yarn berry のグローバルキャッシュをビルドキャッシュに載せる
RUN --mount=type=cache,target=/root/.yarn/berry/cache \
    yarn install --immutable

# Ruby 4.0.8 の公式イメージ（docker-library/ruby）がまだ公開されていないため、
# 公式イメージの Dockerfile（4.0/trixie・4.0/slim-trixie）にならって Ruby を自前でビルドする。
# 公式イメージが公開されたら、以下の ruby-build / ruby / ruby-slim ステージを削除し、
# public.ecr.aws/docker/library/ruby:<version>(-slim) を直接使う形に戻すこと。
FROM public.ecr.aws/docker/library/buildpack-deps:trixie AS ruby-build
ENV RUBY_VERSION=4.0.8
ENV RUBY_DOWNLOAD_URL=https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.8.tar.xz
ENV RUBY_DOWNLOAD_SHA256=3bd35abc39dce9c682d62cf333fbd8b8f34816dd651f8228b3b59353157b84a4
# YJIT / ZJIT のビルドに Rust が必要
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends dpkg-dev libgdbm-dev ruby; \
    \
    rustArch=; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "$dpkgArch" in \
        'amd64') rustArch='x86_64-unknown-linux-gnu'; rustupUrl='https://static.rust-lang.org/rustup/archive/1.28.2/x86_64-unknown-linux-gnu/rustup-init'; rustupSha256='20a06e644b0d9bd2fbdbfd52d42540bdde820ea7df86e92e533c073da0cdd43c' ;; \
        'arm64') rustArch='aarch64-unknown-linux-gnu'; rustupUrl='https://static.rust-lang.org/rustup/archive/1.28.2/aarch64-unknown-linux-gnu/rustup-init'; rustupSha256='e3853c5a252fca15252d07cb23a1bdd9377a8c6f3efa01531109281ae47f841c' ;; \
    esac; \
    if [ -n "$rustArch" ]; then \
        mkdir -p /tmp/rust; \
        wget -O /tmp/rust/rustup-init "$rustupUrl"; \
        echo "$rustupSha256 */tmp/rust/rustup-init" | sha256sum --check --strict; \
        chmod +x /tmp/rust/rustup-init; \
        export RUSTUP_HOME='/tmp/rust/rustup' CARGO_HOME='/tmp/rust/cargo'; \
        export PATH="$CARGO_HOME/bin:$PATH"; \
        /tmp/rust/rustup-init -y --no-modify-path --profile minimal --default-toolchain '1.91.1' --default-host "$rustArch"; \
    fi; \
    \
    wget -O ruby.tar.xz "$RUBY_DOWNLOAD_URL"; \
    echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
    mkdir -p /usr/src/ruby; \
    tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
    cd /usr/src/ruby; \
    autoconf; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    export LDFLAGS='-Wl,-z,relro -Wl,-z,now'; \
    ./configure \
        --build="$gnuArch" \
        --disable-install-doc \
        --enable-shared \
        ${rustArch:+--enable-yjit} \
        ${rustArch:+--enable-zjit} \
    ; \
    make -j "$(nproc)"; \
    make install DESTDIR=/ruby; \
    mkdir -p /ruby/usr/local/etc; \
    echo 'gem: --no-document' >> /ruby/usr/local/etc/gemrc

# 公式イメージ ruby:<version> 相当（ネイティブ拡張の gem をビルドするステージ用）
FROM public.ecr.aws/docker/library/buildpack-deps:trixie AS ruby
ENV LANG=C.UTF-8
ENV RUBY_VERSION=4.0.8
# ruby-build ステージで DESTDIR=/ruby にインストールした /usr/local 以下だけをコピーする
COPY --link --from=ruby-build /ruby/usr/local /usr/local
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH=$GEM_HOME/bin:$PATH
# コピーした libruby.so をローダーのキャッシュに登録する
RUN ldconfig && mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME" && ruby --version

# 公式イメージ ruby:<version>-slim 相当
FROM public.ecr.aws/docker/library/debian:trixie-slim AS ruby-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libffi8 libgmp10 libssl3t64 libyaml-0-2 zlib1g && \
    apt-get dist-clean
ENV LANG=C.UTF-8
ENV RUBY_VERSION=4.0.8
COPY --link --from=ruby-build /ruby/usr/local /usr/local
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH=$GEM_HOME/bin:$PATH
# 実行時ライブラリが不足していればビルドを失敗させる
RUN set -eux; \
    ldconfig; \
    if find /usr/local -type f -name '*.so*' -exec ldd '{}' + | grep 'not found'; then exit 1; fi; \
    mkdir -p "$GEM_HOME"; \
    chmod 1777 "$GEM_HOME"; \
    ruby --version; \
    ruby -ropenssl -ryaml -rzlib -rfiddle -e 'puts OpenSSL::OPENSSL_LIBRARY_VERSION'

FROM ruby AS fetch-lib
WORKDIR /app
COPY --link Gemfile* ./
RUN apt-get update && apt-get install -y --no-install-recommends shared-mime-info libmariadb3
RUN bundle install

FROM ruby AS asset-compile
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
RUN apt-get update && apt-get install -y --no-install-recommends libvips42
ENV AWS_ACCESS_KEY_ID=''
ARG RAILS_ENV='production'
RUN --mount=type=cache,uid=1000,target=/app/tmp/cache SECRET_KEY_BASE=hoge RAILS_ENV=${RAILS_ENV} DREAMKAST_NAMESPACE=dreamkast DB_ADAPTER=nulldb bin/rails assets:precompile

# 同じイメージを Docker Compose の開発環境（fifo-worker など）でも使うため、
# 開発・テスト用の gem と Node.js/Yarn も含める。
FROM ruby-slim

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
# 非 root ユーザーでも node ステージで取得済みの yarn を使えるよう、共有の場所に置く
ENV COREPACK_HOME=/usr/local/share/corepack
COPY --link --from=node /usr/local/bin/node /usr/local/bin/
COPY --link --from=node /usr/local/lib/node_modules/corepack /usr/local/lib/node_modules/corepack
COPY --link --from=node /root/.cache/node/corepack /usr/local/share/corepack
RUN ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable
ARG RAILS_ENV='production'
ENV RAILS_ENV=${RAILS_ENV} RAILS_LOG_TO_STDOUT=ON RAILS_SERVE_STATIC_FILES=enabled
WORKDIR /app
COPY --link --from=node /app/node_modules /app/node_modules
COPY --link --from=fetch-lib /usr/local/bundle /usr/local/bundle
RUN apt-get update && apt-get -y install --no-install-recommends wget ca-certificates libmariadb3 libvips42 chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV CHROME_BIN=/usr/bin/chromium
COPY --link . .
COPY --link --from=asset-compile /app/public /app/public
# RDS 接続の TLS 検証(verify_identity)用に、グローバル CA バンドルをビルド時に取得する
RUN mkdir -p /app/config/certs && \
    wget -q -O /app/config/certs/rds-global-bundle.pem \
      https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
RUN groupadd --gid 1000 app && useradd --uid 1000 --gid app --create-home app && \
    mkdir -p /app/tmp /app/log /app/storage /app/public/uploads && \
    chown -R app:app /app/tmp /app/log /app/storage /app/public/uploads /usr/local/share/corepack
USER app
EXPOSE 3000
ENV RUBY_YJIT_ENABLE=1
ENTRYPOINT ["./entrypoint.sh"]
