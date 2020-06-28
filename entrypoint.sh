#!/bin/bash
rails db:migrate
rails db:seed
rails s -b 0.0.0.0 --dev-caching
