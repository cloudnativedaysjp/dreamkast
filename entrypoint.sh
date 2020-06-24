#!/bin/bash
rm -f tmp/pids/server.pid
bundle install
rails webpacker:install 
rails db:migrate
rails s -b 0.0.0.0
