#!/bin/bash
bundle install
rails webpacker:install 
rails db:migrate
rails s -b 0.0.0.0
