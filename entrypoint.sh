#!/bin/bash
rm -f tmp/pids/server.pid
bundle install
yarn install --check-files
touch tmp/caching-dev.txt 
rails db:migrate
rails s -b 0.0.0.0
