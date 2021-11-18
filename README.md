# dreamkast

Online Conference Platform

## Prerequisites

- Docker Compose
- Auth0 application keys

## How to create auth0 applications keys

See [Auth0 document](https://auth0.com/docs/quickstart/webapp/rails/01-login)

After create configuration, create `.env` file in the top-level directory.

```
AUTH0_CLIENT_ID=FVYbe7dsf1fowelsdlkdsfLwofArfNUznaeku
AUTH0_CLIENT_SECRET=jBeB2Jd4sdfsdfdgetwarzOXYsdEyasdfq3wer3r9wglkj129UoF_XJuD
AUTH0_DOMAIN=yourdomain.auth0.com
```

Docker compose read `.env` file automatically.

If you are running a rails server without Docker compose, you need to set environment variables like this.

```
export AUTH0_CLIENT_ID=FVYbe7dsf1fowelsdlkdsfLwofArfNUznaeku
export AUTH0_CLIENT_SECRET=jBeB2Jd4sdfsdfdgetwarzOXYsdEyasdfq3wer3r9wglkj129UoF_XJuD
export AUTH0_DOMAIN=yourdomain.auth0.com
```

## Setup environment

This repository works with

- Ruby
- Node.js
- Yarn
- Docker Compose (for MySQL and Redis)
- AWS CLI

the version is controlled by `.node-version` and `.ruby-version` file.

`nodenv` and `rbenv` are recommended to install those.

You need to install shared-mime-info

- macOS: `brew install shared-mime-info`
- Ubuntu, Debian: `apt-get install shared-mime-info`

```
$ yarn install --check-files
$ bundle install
$ bundle exec rake webpacker:compile
```

Then, create `.env-local` file and fill these values. If you don't know correct values, please ask us. 

```
export AUTH0_CLIENT_ID=
export AUTH0_CLIENT_SECRET=
export AUTH0_DOMAIN=
export SENTRY_DSN=
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export S3_BUCKET=
export S3_REGION=
export MYSQL_HOST=db
export MYSQL_USER=user
export MYSQL_PASSWORD=password
export MYSQL_DATABASE=dreamkast
export REDIS_URL=redis://redis:6379
export RAILS_MASTER_KEY=
```

Next, configure awscli and logged in registry using it.

```
source .env-local
aws ecr get-login-password | docker login --username AWS --password-stdin http://607167088920.dkr.ecr.ap-northeast-1.amazonaws.com/
```

Then, setup databases, ui and load balancer by running Docker Compose

```
$ docker-compose pull ui
$ docker-compose up -d db redis nginx ui
```

Run the application

```
$ ./entrypoint.sh
```

## For local development

Run Webpack dev server in case you want to edit JavaScript.

```
$ ./bin/webpack-dev-server
```

## DB migration and to add seed data

```
$ bundle exec rails db:migrate
$ bundle exec rails db:seed
```


