Rails.application.config.middleware.use(Prometheus::Middleware::CustomExporter)

prometheus = Prometheus::Client.registry

viwer_count = Prometheus::Client::Gauge.new(
  :dreamkast_viewer_count,
  docstring: "Count dreamkast viewer number",
  labels: [:talk_id, :track_id, :conference_id]
)

chat_count = Prometheus::Client::Gauge.new(
  :dreamkast_chat_count,
  docstring: "Count dreamkast chat number",
  labels: [:conference_id, :talk_id]
)

prometheus.register(viwer_count)
prometheus.register(chat_count)
