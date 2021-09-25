require 'aws-xray'

Aws::Xray.config.name = 'dreamkast'
Aws::Xray.config.client_options = 'xray-service.amazon-cloudwatch:2000'
use Aws::Xray::Rack
