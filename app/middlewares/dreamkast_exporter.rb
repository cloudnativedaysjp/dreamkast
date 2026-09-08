require 'prometheus/middleware/exporter'

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
        :dreamkast_cfp_proposals_count,
        docstring: 'Count CFP proposals',
        labels: [:conference_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_difficulty_count,
        docstring: 'Count CFP proposals by difficulty',
        labels: [:conference_id, :talk_difficulty_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_assumed_visitor_count,
        docstring: 'Count CFP proposals by assumed visitor',
        labels: [:conference_id, :assumed_visitor_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_execution_phase_count,
        docstring: 'Count CFP proposals by execution phase',
        labels: [:conference_id, :execution_phase_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_publication_permission_count,
        docstring: 'Count CFP proposals by publication permission',
        labels: [:conference_id, :publication_permission_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_session_time_count,
        docstring: 'Count CFP proposals by session time',
        labels: [:conference_id, :session_time_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_language_count,
        docstring: 'Count CFP proposals by language',
        labels: [:conference_id, :language_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_cfp_proposals_by_presentation_method_count,
        docstring: 'Count CFP proposals by presentation method',
        labels: [:conference_id, :presentation_method_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_talk_difficulties_count,
        docstring: 'Count dreamkast talk difficulties',
        labels: [:conference_id, :talk_difficulty_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_stats_of_registrants_offline,
        docstring: 'Stats of Registrants(Offline)',
        labels: [:conference_id]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_stats_of_registrants_online,
        docstring: 'Stats of Registrants(Online)',
        labels: [:conference_id]
      )
    ]
    metrics.each do |metric|
      begin
        @registry.register(metric)
      rescue Prometheus::Client::Registry::AlreadyRegisteredError
        # メトリクスが既に登録されている場合はスキップ
      end
    end
  end

  def respond_with(format)
    @cfp_talk_conference_map = nil
    @proposal_item_config_params_maps = nil
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
    profile_counts = Profile.group(:conference_id).count
    Conference.all.each do |conf|
      metrics.set(
        profile_counts[conf.id] || 0,
        labels: { conference_id: conf.id }
      )
    end
  end

  def dreamkast_talks_count(metrics)
    talk_counts = Talk.group(:conference_id).count
    Conference.all.each do |talks_count|
      metrics.set(
        talk_counts[talks_count.id] || 0,
        labels: { conference_id: talks_count.id }
      )
    end
  end

  def dreamkast_cfp_proposals_count(metrics)
    proposal_counts = cfp_talk_conference_map.values.tally

    Conference.find_each do |conference|
      metrics.set(
        proposal_counts[conference.id] || 0,
        labels: { conference_id: conference.id }
      )
    end
  end

  def dreamkast_cfp_proposals_by_difficulty_count(metrics)
    counts = Talk.joins(:talk_difficulty)
                 .where(id: cfp_talk_conference_map.keys)
                 .group('talks.conference_id', 'talk_difficulties.name')
                 .count

    counts.each do |(conference_id, difficulty_name), count|
      metrics.set(
        count,
        labels: { conference_id:, talk_difficulty_name: difficulty_name }
      )
    end
  end

  def dreamkast_cfp_proposals_by_assumed_visitor_count(metrics)
    count_cfp_proposal_items(metrics, label: 'assumed_visitor', value_label_name: :assumed_visitor_name)
  end

  def dreamkast_cfp_proposals_by_execution_phase_count(metrics)
    count_cfp_proposal_items(metrics, label: 'execution_phase', value_label_name: :execution_phase_name)
  end

  def dreamkast_cfp_proposals_by_publication_permission_count(metrics)
    count_cfp_proposal_items(
      metrics,
      label: 'whether_it_can_be_published',
      value_label_name: :publication_permission_name
    )
  end

  def dreamkast_cfp_proposals_by_session_time_count(metrics)
    count_cfp_proposal_items(metrics, label: 'session_time', value_label_name: :session_time_name)
  end

  def dreamkast_cfp_proposals_by_language_count(metrics)
    count_cfp_proposal_items(metrics, label: 'language', value_label_name: :language_name)
  end

  def dreamkast_cfp_proposals_by_presentation_method_count(metrics)
    count_cfp_proposal_items(metrics, label: 'presentation_method', value_label_name: :presentation_method_name)
  end

  def dreamkast_talk_difficulties_count(metrics)
    Talk.count_talks_by_difficulty_and_conference.each do |talk_difficulties_count|
      metrics.set(
        talk_difficulties_count.count,
        labels: { conference_id: talk_difficulties_count.conference_id, talk_difficulty_name: talk_difficulties_count.name }
      )
    end
  end

  def dreamkast_stats_of_registrants_offline(metrics)
    StatsOfRegistrant.all.each do |stats|
      metrics.set(
        stats.offline_attendees.to_i,
        labels: { conference_id: stats.conference_id }
      )
    end
  end

  def dreamkast_stats_of_registrants_online(metrics)
    StatsOfRegistrant.all.each do |stats|
      metrics.set(
        stats.online_attendees.to_i,
        labels: { conference_id: stats.conference_id }
      )
    end
  end

  def cfp_talk_conference_map
    @cfp_talk_conference_map ||= Proposal.joins(talk: :talk_types)
                                         .where(talk_types: { id: TalkType::SESSION_ID })
                                         .pluck(:talk_id, :conference_id)
                                         .to_h
  end

  def proposal_item_config_params_map(label, conference_ids)
    @proposal_item_config_params_maps ||= {}
    @proposal_item_config_params_maps[label] ||= ProposalItemConfig
                                                 .where(conference_id: conference_ids, label:)
                                                 .pluck(:conference_id, :id, :params)
                                                 .to_h { |conference_id, id, params| [[conference_id, id], params] }
  end

  def count_cfp_proposal_items(metrics, label:, value_label_name:)
    talk_conference_map = cfp_talk_conference_map
    config_map = proposal_item_config_params_map(label, talk_conference_map.values.uniq)
    counts = Hash.new(0)

    ProposalItem.where(talk_id: talk_conference_map.keys, label:).find_each do |item|
      conference_id = talk_conference_map[item.talk_id]

      Array(item.params).compact.each do |config_id|
        name = config_map[[conference_id, config_id.to_i]]
        counts[[conference_id, name]] += 1 if name
      end
    end

    counts.each do |(conference_id, name), count|
      metrics.set(
        count,
        labels: { conference_id:, value_label_name => name }
      )
    end
  end
end
