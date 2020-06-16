#!/bin/bash
rails db:migrate RAILS_ENV=development
rails s -b 0.0.0.0
