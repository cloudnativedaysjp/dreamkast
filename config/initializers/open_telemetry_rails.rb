require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.use_all
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(host: ENV['JAEGER_AGENT_ADDR'] || 'jaeger-tracing-agent.monitoring', port: 6831)
    )
  )
  c.service_name = ENV['DREAMKAST_NAMESPACE'] || 'dreamkast-dev'
  c.service_version = '0.1.0'
end

# In case you want to customize trace spans
# tracer = OpenTelemetry.tracer_provider.tracer(ENV["DREAMKAST_NAMESPACE"], "0.1.0")
