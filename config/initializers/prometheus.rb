# prometheus.rb
require 'prometheus/client'
require 'prometheus/middleware/exporter'

module Prometheus
  module Controller
    metrics_prefix = 'dreamkast'
    prometheus = Prometheus::Client.registry
    VIEWER_COUNT = Prometheus::Client::Gauge.new(
      "#{metrics_prefix}_viewer_count".to_sym,
      docstring: "Count #{metrics_prefix} viewer number",
      labels: [:talk_id, :track_id, :conference_id]
    )

    CHAT_COUNT = Prometheus::Client::Gauge.new(
      "#{metrics_prefix}_chat_count".to_sym,
      docstring: "Count #{metrics_prefix} chat number",
      labels: [:conference_id, :talk_id]
    )

    prometheus.register(VIEWER_COUNT)
    prometheus.register(CHAT_COUNT)
  end

  module Middleware
    class CustomExporter < Prometheus::Middleware::Exporter
      def respond_with(format)
        calculate_viewer_count
        calculate_chat_count
        super
      end

      private

      def calculate_viewer_count
        vcs = ViewerCount.all
        vcs.each do |vc|
          Prometheus::Controller::VIEWER_COUNT.set(
            vc.count,
            labels: { talk_id: vc.talk_id, track_id: vc.track_id, conference_id: vc.conference_id }
          )
        end
      end

      def calculate_chat_count
        chat_counts = ChatMessage.all.select(
          [
            :conference_id, :speaker_id, ChatMessage.arel_table[:speaker_id].count.as('count')
          ]
        ).group(:conference_id, :speaker_id)

        chat_counts.each do |chat_count|
          talk_id = TalksSpeaker.where(speaker_id: chat_count.speaker_id).limit(1)[0].talk_id
          Prometheus::Controller::CHAT_COUNT.set(
            chat_count.count,
            labels: { conference_id: chat_count.conference_id, talk_id: talk_id }
          )
        end
      end
    end
  end
end
