# prometheus.rb
require 'prometheus/client'
require 'prometheus/middleware/exporter'

module Prometheus
  module Controller
    metrics_prefix = 'dreamkast'
    prometheus = Prometheus::Client.registry
    VIEWER_COUNT = Prometheus::Client::Gauge.new("#{metrics_prefix}_viewer_count".to_sym, docstring: "Count #{metrics_prefix} viewer number", labels: [:track_id])
    CHAT_COUNT = Prometheus::Client::Gauge.new("#{metrics_prefix}_chat_count".to_sym, docstring: "Count #{metrics_prefix} chat number", labels: [:room_id])

    prometheus.register(VIEWER_COUNT)
    prometheus.register(CHAT_COUNT)
  end

  module Middleware
    class CustomExporter < Prometheus::Middleware::Exporter
      def respond_with(format)
        conferences = Conference.all
        puts(conferences)
        conferences.each do |conference|
          tracks = Track.where(conference_id: conference.id)
          tracks.each do |track|
            vc = ViewerCount.where(track_id: track.id).order(created_at: :desc).limit(1)[0]
            puts(vc.to_s)
            unless vc.nil?
              Prometheus::Controller::VIEWER_COUNT.set(vc.count, labels: { track_id: track.id })
            end
          end
          chat_counts = ChatMessage.where(conference_id: conference.id).group('room_id').count

          chat_counts.each do |chat_count|
            Prometheus::Controller::CHAT_COUNT.set(chat_count.count_all, labels: { room_id: chat_count.chat_messages_room_id })
          end
        end

        super
      end
    end
  end
end
