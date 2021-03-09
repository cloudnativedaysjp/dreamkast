# syntax = docker/dockerfile:experimental

FROM ruby:2.7.2 AS nodejs

WORKDIR /tmp

# Node.jsのダウンロード
RUN curl -LO https://nodejs.org/dist/v12.18.2/node-v12.18.2-linux-x64.tar.xz
RUN tar xvf node-v12.18.2-linux-x64.tar.xz
RUN mv node-v12.18.2-linux-x64 node

FROM ruby:2.7.2
# nodejsをインストールしたイメージからnode.jsをコピーする
COPY --from=nodejs /tmp/node /opt/node
ENV PATH /opt/node/bin:$PATH

# yarnのインストール
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH /root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH

# ruby-2.7.0でnewした場合を考慮
RUN gem install bundler

WORKDIR /app

# Dockerのビルドステップキャッシュを利用するため
# 先にGemfileを転送し、bundle installする
COPY Gemfile Gemfile.lock package.json yarn.lock /app/

RUN bundle config set app_config .bundle
RUN bundle config set path .cache/bundle
# mount cacheを利用する
RUN bundle install && \
    mkdir -p vendor && \
    cp -ar .cache/bundle vendor/bundle
RUN bundle config set path vendor/bundle

RUN /root/.yarn/bin/yarn install --modules-folder .cache/node_modules && \
    cp -ar .cache/node_modules node_modules

COPY . /app

ENV AWS_ACCESS_KEY_ID=''
RUN SECRET_KEY_BASE=hoge RAILS_ENV=production DB_ADAPTER=nulldb bin/rails assets:precompile

EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
