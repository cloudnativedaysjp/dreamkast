#!/bin/bash
rails db:migrate
rails db:seed
rm -f tmp/pids/server.pid
rails s -b 0.0.0.0 --dev-caching
