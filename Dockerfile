FROM node:12.18.1-slim as front
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --check-files

FROM ruby:2.7.1 as fetch-lib
WORKDIR /app
COPY Gemfile* ./
RUN bundle install

FROM ruby:2.7.1-slim

ENV YARN_VERSION 1.22.4
COPY --from=front /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=front /usr/local/bin/node /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

ENV RAILS_ENV=development, RAILS_LOG_TO_STDOUT=ON
WORKDIR /app
COPY --from=front /app/node_modules /app/node_modules
COPY --from=fetch-lib /usr/local/bundle /usr/local/bundle
COPY . .
EXPOSE 3000
CMD ["./entrypoint.sh"]
