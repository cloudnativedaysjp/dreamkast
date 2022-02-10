module Prometheus
  module Middleware
    class CustomExporter < Prometheus::Middleware::Exporter
      def respond_with(format)
        @registry.metrics.each do |metrics|
          send(metrics.name, metrics)
        end
        super
      end

      private

      def dreamkast_viewer_count(metrics)
        ViewerCount.latest_viewer_counts.each do |vc|
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
