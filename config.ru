# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'prometheus/middleware/exporter'
use Prometheus::Middleware::CustomExporter
run Rails.application
