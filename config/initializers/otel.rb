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

  if ENV['OTEL_ENDPOINT'].present?
    exporter = OpenTelemetry::Exporter::OTLP::Exporter.new(
      endpoint: ENV['OTEL_ENDPOINT'],
      headers: {
        'Accept' => '*/*'
      }
    )
  else
    Rails.logger.warn('OTEL_ENDPOINT not set - using console exporter for OpenTelemetry')
    exporter = OpenTelemetry::SDK::Trace::Export::ConsoleSpanExporter.new
  end
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(exporter)
  )

  c.use_all
end
