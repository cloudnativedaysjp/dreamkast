class DreamkastExporter < Prometheus::Middleware::Exporter
  def initialize(app, options = {})
    super
    metrics = [
      Prometheus::Client::Gauge.new(
        :dreamkast_track_viewer_count,
        docstring: 'Count dreamkast viewer number by track',
        labels: [:track_id, :conference_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_talk_viewer_count,
        docstring: 'Count dreamkast viewer number by talk',
        labels: [:talk_id, :conference_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_chat_count,
        docstring: 'Count dreamkast chat number',
        labels: [:conference_id, :talk_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_registrants_count,
        docstring: 'Count dreamkast registrants number',
        labels: [:conference_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_talks_count,
        docstring: 'Count dreamkast talks number',
        labels: [:conference_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_talk_difficulties_count,
        docstring: 'Count dreamkast talk difficulties',
        labels: [:conference_id, :talk_difficulty_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_count_proposal_items,
        docstring: 'count dreamkast proposal items',
        labels: [:conference_id, :proposal_items_label, :proposal_items_params]
      )
    ]
    metrics.each do |metric|
      @registry.register(metric)
    end
  end

  def respond_with(format)
    @registry.metrics.each do |metrics|
      send(metrics.name, metrics)
    end
    super
  end

  private

  def dreamkast_track_viewer_count(metrics)
    ViewerCount.latest_number_of_viewers.each do |vc|
      metrics.set(
        vc.count,
        labels: { track_id: vc.track_id, conference_id: vc.conference_id }
      )
    end
  end

  def dreamkast_talk_viewer_count(metrics)
    ViewerCount.latest_number_of_viewers.each do |vc|
      metrics.set(
        vc.count,
        labels: { talk_id: vc.talk_id, conference_id: vc.conference_id }
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

  def dreamkast_registrants_count(metrics)
    Conference.all.each do |conf|
      metrics.set(
        conf.profiles.count,
        labels: { conference_id: conf.id }
      )
    end
  end

  def dreamkast_talks_count(metrics)
    Conference.all.each do |talks_count|
      metrics.set(
        talks_count.talks.count,
        labels: { conference_id: talks_count.id }
      )
    end
  end

  def dreamkast_talk_difficulties_count(metrics)
    Talk.count_talks_by_difficulty_and_conference.each do |talk_difficulties_count|
      metrics.set(
        talk_difficulties_count.count,
        labels: { conference_id: talk_difficulties_count.conference_id, talk_difficulty_name: talk_difficulties_count.name }
      )
    end
  end

  def dreamkast_count_proposal_items(metrics)
    ProposalItem.count_proposal_items.each do |proposal_item|
      metrics.set(
        proposal_item.count,
        labels: {
          conference_id: proposal_item.conference_id,
          proposal_items_label: proposal_item.label,
          proposal_items_params: proposal_item.value_name
        }
      )
    end
  end
end
