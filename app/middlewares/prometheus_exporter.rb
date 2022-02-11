module Prometheus
  module Middleware
    class DreamkastExporter < Prometheus::Middleware::Exporter
      def initialize(app, options = {})
        super
        viwer_count = Prometheus::Client::Gauge.new(
          :dreamkast_viewer_count,
          docstring: 'Count dreamkast viewer number',
          labels: [:talk_id, :track_id, :conference_id]
        )

        chat_count = Prometheus::Client::Gauge.new(
          :dreamkast_chat_count,
          docstring: 'Count dreamkast chat number',
          labels: [:conference_id, :talk_id]
        )

        @registry.register(viwer_count)
        @registry.register(chat_count)
      end

      def respond_with(format)
        @registry.metrics.each do |metrics|
          send(metrics.name, metrics)
        end
        super
      end

      private

      def dreamkast_viewer_count(metrics)
        ViewerCount.latest_number_of_viewers.each do |vc|
          metrics.set(
            vc.count,
            labels: { talk_id: vc.talk_id, track_id: vc.track_id, conference_id: vc.conference_id }
          )
        end
      end

      def dreamkast_chat_count(metrics)
        ChatMessage.counts.each do |chat_count|
          metrics.set(
            chat_count.count,
            labels: { conference_id: chat_count.conference_id, talk_id: chat_count.room_id }
          )
        end
      end
    end
  end
end
