require 'prometheus/middleware/exporter'

class DreamkastExporter < Prometheus::Middleware::Exporter
  # CFP プロポーザルの選択式項目のラベルと、メトリクスに付与するラベル名の対応
  CFP_PROPOSAL_ITEM_LABELS = {
    'assumed_visitor' => :assumed_visitor_name,
    'execution_phase' => :execution_phase_name,
    'whether_it_can_be_published' => :publication_permission_name,
    'session_time' => :session_time_name,
    'language' => :language_name,
    'presentation_method' => :presentation_method_name
  }.freeze

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
        :dreamkast_talk_categories_count,
        docstring: 'Count dreamkast talk categories',
        labels: [:conference_id, :talk_category_name]
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
    reset_cfp_caches
    @registry.metrics.each do |metrics|
      send(metrics.name, metrics)
    end
    super
  end

  private

  # スクレイプ毎に集計結果をリセットする（プロセス内で使い回さない）
  def reset_cfp_caches
    @cfp_proposal_counts_by_conference = nil
    @cfp_proposal_counts_by_difficulty = nil
    @cfp_proposal_item_counts = nil
    @cfp_proposal_item_configs = nil
    @cfp_proposal_item_config_names = nil
    @cfp_proposal_item_config_names_by_label = nil
  end

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
    proposal_counts = cfp_proposal_counts_by_conference

    Conference.find_each do |conference|
      metrics.set(
        proposal_counts[conference.id] || 0,
        labels: { conference_id: conference.id }
      )
    end
  end

  def dreamkast_cfp_proposals_by_difficulty_count(metrics)
    counts = cfp_proposal_counts_by_difficulty

    TalkDifficulty.where.not(conference_id: nil).pluck(:conference_id, :name).uniq.each do |conference_id, name|
      metrics.set(
        counts[[conference_id, name]] || 0,
        labels: { conference_id:, talk_difficulty_name: name }
      )
    end
  end

  def dreamkast_cfp_proposals_by_assumed_visitor_count(metrics)
    count_cfp_proposal_items(metrics, label: 'assumed_visitor')
  end

  def dreamkast_cfp_proposals_by_execution_phase_count(metrics)
    count_cfp_proposal_items(metrics, label: 'execution_phase')
  end

  def dreamkast_cfp_proposals_by_publication_permission_count(metrics)
    count_cfp_proposal_items(metrics, label: 'whether_it_can_be_published')
  end

  def dreamkast_cfp_proposals_by_session_time_count(metrics)
    count_cfp_proposal_items(metrics, label: 'session_time')
  end

  def dreamkast_cfp_proposals_by_language_count(metrics)
    count_cfp_proposal_items(metrics, label: 'language')
  end

  def dreamkast_cfp_proposals_by_presentation_method_count(metrics)
    count_cfp_proposal_items(metrics, label: 'presentation_method')
  end

  def dreamkast_talk_difficulties_count(metrics)
    Talk.count_talks_by_difficulty_and_conference.each do |talk_difficulties_count|
      metrics.set(
        talk_difficulties_count.count,
        labels: { conference_id: talk_difficulties_count.conference_id, talk_difficulty_name: talk_difficulties_count.name }
      )
    end
  end

  def dreamkast_talk_categories_count(metrics)
    category_counts = Talk.joins(:talk_category)
                          .where.not(talks: { conference_id: 15 })
                          .group('talks.conference_id', 'talk_categories.name')
                          .count

    TalkCategory.where.not(conference_id: [nil, 15]).where.not(name: nil).pluck(:conference_id, :name).uniq.each do |conference_id, name|
      metrics.set(
        category_counts[[conference_id, name]] || 0,
        labels: { conference_id:, talk_category_name: name }
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

  # CFP（一般公募セッション）のプロポーザル数を conference ごとに集計する
  def cfp_proposal_counts_by_conference
    @cfp_proposal_counts_by_conference ||= Proposal.joins(talk: :talk_types)
                                                   .where(talk_types: { id: TalkType::SESSION_ID })
                                                   .group('proposals.conference_id')
                                                   .count
  end

  # CFP のプロポーザル数を conference と受講者レベルごとに集計する
  def cfp_proposal_counts_by_difficulty
    @cfp_proposal_counts_by_difficulty ||= Talk.joins(:proposal, :talk_difficulty, :talk_types)
                                               .where(talk_types: { id: TalkType::SESSION_ID })
                                               .group('talks.conference_id', 'talk_difficulties.name')
                                               .count
  end

  def cfp_proposal_item_counts
    @cfp_proposal_item_counts ||= aggregate_cfp_proposal_item_counts
  end

  # 全ラベル分の選択式項目を 1 回のクエリで取得し、ラベルごとに集計する
  def aggregate_cfp_proposal_item_counts
    name_map = cfp_proposal_item_config_names
    counts = {}

    ProposalItem.joins(talk: [:proposal, :talk_types])
                .where(talk_types: { id: TalkType::SESSION_ID })
                .where(label: CFP_PROPOSAL_ITEM_LABELS.keys)
                .pluck(:conference_id, :label, :params)
                .each do |conference_id, label, params|
      # params はラジオボタンなら String、チェックボックスなら Array
      Array(params).compact.each do |config_id|
        name = name_map[[conference_id, label, config_id.to_i]]
        next unless name

        counts[label] ||= Hash.new(0)
        counts[label][[conference_id, name]] += 1
      end
    end

    counts
  end

  def cfp_proposal_item_configs
    @cfp_proposal_item_configs ||= ProposalItemConfig
                                   .where(label: CFP_PROPOSAL_ITEM_LABELS.keys)
                                   .pluck(:conference_id, :id, :label, :params)
  end

  def cfp_proposal_item_config_names
    @cfp_proposal_item_config_names ||=
      cfp_proposal_item_configs.to_h { |conference_id, id, label, params| [[conference_id, label, id], params] }
  end

  # ゼロ埋めの対象となる「conference と選択肢名」の組み合わせをラベルごとに列挙する
  def cfp_proposal_item_config_names_by_label
    @cfp_proposal_item_config_names_by_label ||=
      cfp_proposal_item_configs.each_with_object({}) do |(conference_id, _id, label, params), map|
        next if params.blank?

        (map[label] ||= []) << [conference_id, params]
      end.transform_values(&:uniq)
  end

  def count_cfp_proposal_items(metrics, label:)
    value_label_name = CFP_PROPOSAL_ITEM_LABELS.fetch(label)
    counts = cfp_proposal_item_counts[label] || {}

    # 該当のプロポーザルが無い選択肢にも 0 を set し、古い値が残り続けるのを防ぐ
    cfp_proposal_item_config_names_by_label[label].to_a.each do |conference_id, name|
      metrics.set(
        counts[[conference_id, name]] || 0,
        labels: { conference_id:, value_label_name => name }
      )
    end
  end
end
