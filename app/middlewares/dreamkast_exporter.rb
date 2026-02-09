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
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_assumed_visitors_by_category_count,
        docstring: 'Count assumed visitors by category',
        labels: [:conference_id, :target_conference, :assumed_visitor_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_execution_phases_by_category_count,
        docstring: 'Count execution phases by category',
        labels: [:conference_id, :target_conference, :execution_phase_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_publication_permissions_by_category_count,
        docstring: 'Count publication permissions by category',
        labels: [:conference_id, :target_conference, :publication_permission_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_session_times_by_category_count,
        docstring: 'Count session times by category',
        labels: [:conference_id, :target_conference, :session_time_name]
      ),
      Prometheus::Client::Gauge.new(
        :dreamkast_languages_by_category_count,
        docstring: 'Count languages by category',
        labels: [:conference_id, :target_conference, :language_name]
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
    @category_talk_ids_map = nil
    @proposal_item_config_params_map = nil
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

  def dreamkast_assumed_visitors_by_category_count(metrics)
    config_map = proposal_item_config_params_map
    label_to_category = {
      'cnd_assumed_visitor' => 'cnd_category',
      'pek_assumed_visitor' => 'pek_category',
      'srek_assumed_visitor' => 'srek_category'
    }

    items = ProposalItem.where(
      label: label_to_category.keys,
      conference_id: CONFERENCE_ID
    )

    # カテゴリ x 名称でカウント
    counts = Hash.new(0)
    items.each do |item|
      category = label_to_category[item.label]
      # CheckBox: params は配列
      Array(item.params).compact.each do |pid|
        name = config_map[pid.to_i]
        counts[[category, name]] += 1 if name
      end
    end

    counts.each do |(category, name), count|
      metrics.set(count, labels: {
                    conference_id: CONFERENCE_ID,
        target_conference: category,
        assumed_visitor_name: name
                  })
    end
  end

  def dreamkast_execution_phases_by_category_count(metrics)
    count_by_category(metrics, label: 'execution_phase', value_label_name: 'execution_phase_name', is_checkbox: true)
  end

  def dreamkast_publication_permissions_by_category_count(metrics)
    count_by_category(metrics, label: 'whether_it_can_be_published', value_label_name: 'publication_permission_name', is_checkbox: false)
  end

  def dreamkast_session_times_by_category_count(metrics)
    count_by_category(metrics, label: 'session_time', value_label_name: 'session_time_name', is_checkbox: false)
  end

  def dreamkast_languages_by_category_count(metrics)
    count_by_category(metrics, label: 'language', value_label_name: 'language_name', is_checkbox: false)
  end

  # カテゴリ別talk_idマッピング(リクエスト内キャッシュ)
  # 結果: { "cnd_category" => [1, 2], "pek_category" => [3], "srek_category" => [4] }
  def category_talk_ids_map
    @category_talk_ids_map ||= ProposalItem
                               .where(label: %w[cnd_category pek_category srek_category], conference_id: CONFERENCE_ID)
                               .pluck(:label, :talk_id)
                               .group_by(&:first)
                               .transform_values { |pairs| pairs.map(&:last).uniq }
  end

  # ProposalItemConfig ID -> params(名称) マッピング(リクエスト内キャッシュ)
  def proposal_item_config_params_map
    @proposal_item_config_params_map ||= ProposalItemConfig
                                         .where(conference_id: CONFERENCE_ID)
                                         .pluck(:id, :params)
                                         .to_h
  end

  # 共通label(execution_phase等)のカテゴリ別集計
  # is_checkbox: true の場合、params を配列として展開してカウント
  def count_by_category(metrics, label:, value_label_name:, is_checkbox:)
    config_map = proposal_item_config_params_map

    category_talk_ids_map.each do |category, talk_ids|
      items = ProposalItem.where(talk_id: talk_ids, label:, conference_id: CONFERENCE_ID)
      counts = Hash.new(0)

      items.each do |item|
        param_ids = is_checkbox ? Array(item.params) : [item.params]
        param_ids.compact.each do |pid|
          name = config_map[pid.to_i]
          counts[name] += 1 if name
        end
      end

      counts.each do |name, count|
        metrics.set(count, labels: {
                      conference_id: CONFERENCE_ID,
          target_conference: category,
          value_label_name.to_sym => name
                    })
      end
    end
  end
end
