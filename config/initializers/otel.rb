# OpenTelemetry configuration for Mackerel
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'dreamkast'
  c.service_version = '1.0.0'

  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    OpenTelemetry::SemanticConventions::Resource::DEPLOYMENT_ENVIRONMENT => Rails.env.to_s,
    OpenTelemetry::SemanticConventions::Resource::HOST_NAME => Socket.gethostname
  )

  if ENV['MACKEREL_APIKEY'].present?
    exporter = OpenTelemetry::Exporter::OTLP::Exporter.new(
      endpoint: 'https://otlp-vaxila.mackerelio.com/v1/traces',
      headers: {
        'Accept' => '*/*',
        'Mackerel-Api-Key' => ENV['MACKEREL_APIKEY']
      }
    )
  else
    Rails.logger.warn 'MACKEREL_APIKEY not set - using console exporter for OpenTelemetry'
    exporter = OpenTelemetry::SDK::Trace::Export::ConsoleSpanExporter.new
  end
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(exporter)
  )

  c.use_all
end
