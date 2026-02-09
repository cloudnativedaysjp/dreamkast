require 'prometheus/middleware/exporter'

class DreamkastExporter < Prometheus::Middleware::Exporter
  # クラウドネイティブ会議のconference_id
  CONFERENCE_ID = 15

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
        :dreamkast_select_talks,
        docstring: 'Select dreamkast talks',
        labels: [:talk_id, :conference_id, :title, :talk_difficulty_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_select_proposal_items,
        docstring: 'Select dreamkast proposal items',
        labels: [:talk_id, :conference_id, :proposal_items_label, :proposal_items_params]
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
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_talk_difficulties_by_category_count,
        docstring: 'Count talks by category and difficulty',
        labels: [:conference_id, :target_conference, :talk_difficulty_name]
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

  def dreamkast_talk_difficulties_count(metrics)
    Talk.count_talks_by_difficulty_and_conference.each do |talk_difficulties_count|
      metrics.set(
        talk_difficulties_count.count,
        labels: { conference_id: talk_difficulties_count.conference_id, talk_difficulty_name: talk_difficulties_count.name }
      )
    end
  end

  def dreamkast_select_talks(metrics)
    Talk.preload(:talk_difficulty).all.each do |talk|
      metrics.set(
        talk.id,
        labels: { talk_id: talk.id, conference_id: talk.conference_id, title: talk.title, talk_difficulty_name: talk.talk_difficulty&.name }
      )
    end
  end

  def dreamkast_select_proposal_items(metrics)
    ProposalItem.all.each do |proposal_items|
      metrics.set(
        proposal_items.talk_id,
        labels: { talk_id: proposal_items.talk_id, conference_id: proposal_items.conference_id, proposal_items_label: proposal_items.label, proposal_items_params: proposal_items.params }
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

  def dreamkast_talk_difficulties_by_category_count(metrics)
    target_labels = %w[cnd_category pek_category srek_category]

    # CND/PEK/SREK別に難易度別トーク数を1クエリで集計
    # 同じトークが複数のカテゴリに属する場合、各カテゴリで個別にカウントされる
    # 結果: { ["cnd_category", "初級者 - Beginner"] => 2, ... }
    counts = Talk.joins(:talk_difficulty, :proposal_items)
                 .where(proposal_items: { label: target_labels, conference_id: CONFERENCE_ID })
                 .group('proposal_items.label', 'talk_difficulties.name')
                 .count

    counts.each do |(category_label, difficulty_name), count|
      metrics.set(
        count,
        labels: {
          conference_id: CONFERENCE_ID,
          target_conference: category_label,
          talk_difficulty_name: difficulty_name
        }
      )
    end
  end
end
