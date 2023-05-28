OpenTelemetry::SDK.configure do |c|
  c.use_all
  c.add_span_processor(Sentry::OpenTelemetry::SpanProcessor.instance)
end

OpenTelemetry.propagation = Sentry::OpenTelemetry::Propagator.new
