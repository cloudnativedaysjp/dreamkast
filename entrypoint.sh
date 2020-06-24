#!/bin/bash
rm -f tmp/pids/server.pid
bundle install
yarn install --check-files
rails db:migrate
rails s -b 0.0.0.0 --dev-caching
