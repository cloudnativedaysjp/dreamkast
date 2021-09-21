require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/all'

ENV['OTEL_SERVICE_NAME'] = 'dreamkast'
ENV['OTEL_SERVICE_VERSION'] = '0.1.0'

OpenTelemetry::SDK.configure do |c|
    c.use_all()
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
         OpenTelemetry::Exporter::Jaeger::AgentExporter.new(host: 'simplest-agent.observability', port: 6831)
      )
    )
  end

tracer = OpenTelemetry.tracer_provider.tracer('dreamkast', '0.1.0')
