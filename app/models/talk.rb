# == Schema Information
#
# Table name: talks
#
#  id                    :bigint           not null, primary key
#  abstract              :text(65535)
#  document_url          :string(255)
#  end_time              :time
#  execution_phases      :json
#  expected_participants :json
#  movie_url             :string(255)
#  show_on_timetable     :boolean
#  start_time            :time
#  title                 :string(255)
#  video_published       :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  conference_day_id     :integer
#  conference_id         :integer
#  sponsor_id            :integer
#  talk_category_id      :bigint
#  talk_difficulty_id    :bigint
#  talk_time_id          :integer
#  track_id              :integer
#
# Indexes
#
#  index_talks_on_talk_category_id    (talk_category_id)
#  index_talks_on_talk_difficulty_id  (talk_difficulty_id)
#
class Talk < ApplicationRecord
  belongs_to :talk_category, optional: true
  belongs_to :talk_difficulty, optional: true
  belongs_to :conference
  belongs_to :conference_day, optional: true
  belongs_to :track, optional: true
  belongs_to :sponsor, optional: true
  has_one :proposal

  has_one :video_registration, dependent: :destroy
  has_one :video, dependent: :destroy
  belongs_to :talk_time, optional: true
  has_many :talks_speakers
  has_many :registered_talks
  has_many :speakers, through: :talks_speakers
  has_many :profiles, through: :registered_talks

  has_many :proposal_items, autosave: true, dependent: :destroy

  validates :conference_id, presence: true
  validates :title, presence: true

  # エントリー時、セッション概要は空白でもいいのでバリデーションしなくていい
  # validates :abstract, presence: true

  # エントリーフォームから入力する時、以下のフィールドには入力しないのでバリデーションを削っている
  # validates :track_id, presence: true
  # validates :talk_category_id, presence: true
  # validates :talk_difficulty_id, presence: true
  # validates :conference_day_id, presence: true
  # validates :start_time, presence: true
  # validates :end_time, presence: true
  validate :validate_proposal_item_configs, on: :entry_form

  SLOT_MAP = ['1200', '1400', '1500', '1600', '1700', '1800', '1900', '2000']

  scope :on_air, -> {
    includes(:video).where(videos: { on_air: 1 })
  }

  scope :show_on_timetable, -> {
    includes(:proposal).where(show_on_timetable: true, proposals: { status: :accepted })
  }

  scope :accepted, -> {
    includes(:proposal).where(proposals: { status: :accepted })
  }

  scope :rejected, -> {
    includes(:proposal).where(proposals: { status: :rejected })
  }

  scope :accepted_and_intermission, -> {
    includes(:proposal).merge(where(proposals: { status: :accepted }).or(where(abstract: 'intermission')))
  }

  def self.export_csv(conference, talks, track_name = 'all', date = 'all')
    filename = "#{conference.abbr}_#{date}_#{track_name}"
    columns = %w[id title abstract speaker session_time difficulty category created_at twitter_id company start_to_end]
    labels = conference.proposal_item_configs.map(&:label).uniq
    labels.delete('session_time')
    columns.concat(labels)

    csv = CSV.generate do |csv|
      # カラム名を1行目として入れる
      csv << columns

      talks.each do |talk|
        row = [talk.id,
               talk.title,
               talk.abstract,
               talk.speaker_names.join('/ '),
               talk.time,
               talk.talk_difficulty.name,
               talk.talk_category.name,
               talk.created_at,
               talk.speaker_twitter_ids.join('/ '),
               talk.speaker_company_names.join('/ '),
               talk.start_to_end]
        labels.each do |label|
          v = talk.proposal_item_value(label)
          row << (v.instance_of?(Array) ? v.join(', ') : v)
        end
        csv << row
      end
    end

    File.open("./#{filename}.csv", 'w', encoding: 'UTF-8') do |file|
      file.write(csv)
    end

    filename
  end

  def self.updatable_attributes
    [
      'id',
      'conference_id',
      'title',
      'abstract',
      'track_id',
      'talk_category_id',
      'talk_difficulty_id',
      'conference_day_id',
      'start_time',
      'end_time',
      'movie_url',
      'show_on_timetable',
      'video_published',
      'document_url',
      'additional_documents'
    ]
  end

  def track_name
    track.present? ? track.name : ''
  end

  def slot_number
    SLOT_MAP.each_with_index do |time, index|
      if time > start_time.to_time.strftime('%H%M')
        return index.to_s
      end
    end
  end

  def talk_number
    conference_day_id.to_s + track.name + slot_number
  end

  def day_slot
    conference_day_id.to_s + '_' + slot_number
  end

  def row_start
    ((start_time.in_time_zone('Asia/Tokyo') - Time.zone.parse('2000-01-01 12:00')) / 60 / 5).to_i + 1
  end

  def row_end
    ((end_time - start_time).to_i / 60 / 5) + row_start
  end

  def self.find_by_params(day_id, slot_number_param, track_id)
    after = Time.zone.parse(SLOT_MAP[slot_number_param.to_i - 1].dup.insert(2, ':')).utc.strftime('%T')
    before = (Time.zone.parse(SLOT_MAP[slot_number_param.to_i].dup.insert(2, ':')) - 60).utc.strftime('%T')

    where(conference_day_id: day_id, track_id: track_id)
      .where("TIME(start_time) BETWEEN '#{after}' AND '#{before}'")
  end

  def speaker_names
    speakers.map(&:name)
  end

  def speaker_company_names
    speakers.map(&:company)
  end

  def speaker_twitter_ids
    speakers.map(&:twitter_id)
  end

  def difficulty
    talk_difficulty.present? ? talk_difficulty.name : ''
  end

  def category
    talk_category.present? ? talk_category.name : ''
  end

  def duration
    talk_time.present? ? talk_time.time_minutes : 0
  end

  def on_air?
    video.present? ? video.on_air : false
  end

  def video_platform
    video.present? ? video.site : ''
  end

  def video_id
    video.present? ? video.video_id : ''
  end

  def time
    # CICD2021は全セッション40分固定で、talk_timeを持たせていないため
    return 40 if conference.abbr == 'cicd2021'

    # CNDT2021移行はセッションの時間をProposalItemで管理するので、ProposalItemにsession_timeがあればそこからセッション時間を取得して返す
    session_time = proposal_items.find_by(label: 'session_time')
    return ProposalItemConfig.find(session_time.params.to_i).params.split('min')[0].to_i if session_time

    talk_time.present? ? talk_time.time_minutes : 0
  end

  def start_to_end
    if start_time.present? && end_time.present?
      start_time.strftime('%H:%M') + '-' + end_time.strftime('%H:%M')
    else
      ''
    end
  end

  def expected_participant_params
    proposal_item_value('assumed_visitor')
  end

  def execution_phase_params
    proposal_item_value('execution_phase')
  end

  def archived?
    now = Time.now.in_time_zone('Tokyo')
    etime = DateTime.parse("#{conference_day.date.strftime('%Y-%m-%d')} #{end_time.strftime('%H:%M')} +0900")
    (now.to_i - etime.to_i) >= 600
  end

  def sponsor_session?
    sponsor.present?
  end

  def create_or_update_proposal_item(label, params)
    item = proposal_items.find_by(label: label)
    if item.present?
      item.update(params: params)
    else
      proposal_items.build(conference_id: conference_id, label: label, params: params)
    end
  end

  def proposal_item_value(label)
    params = proposal_items.find_by(label: label)&.params
    return nil unless params

    case params
    when String
      ProposalItemConfig.find(params.to_i).params
    when Array
      params.map { |param| ProposalItemConfig.find(param.to_i).params }
    end
  end

  def selected_proposal_items
    r = {}
    conference.proposal_item_configs.map(&:item_number).uniq.each do |item_number|
      proposal_item_config = conference.proposal_item_configs.find_by(item_number: item_number)
      params = proposal_items.find_by(label: proposal_item_config.label)&.params
      return r unless params
      case params
      when String
        r[proposal_item_config.item_name] = ProposalItemConfig.find(params).params
      when Array
        f = ProposalItemConfig.where(id: params.shift)
        a = params.inject(f) do |self_obj, id|
          self_obj.or(ProposalItemConfig.where(id: id))
        end
        r[proposal_item_config.item_name] = a.map(&:params).join(', ')
      end
    end
    r
  end

  private

  def validate_proposal_item_configs
    expected = conference.proposal_item_configs.pluck(:label).uniq
    shorted_items = expected - proposal_items.map(&:label)
    shorted_items.each { |e|
      short = ProposalItemConfig.find_by(label: e).item_name.gsub(/（★*）/, '')
      errors.add(:base, "#{short}は最低1項目選択してください")
    }
  end
end
