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
  validate :validate_expected_participants
  validate :validate_execution_phases

  SLOT_MAP = ["1200","1400","1500","1600","1700","1800","1900","2000"]

  scope :on_air, -> {
    includes(:video).where(videos: { on_air: 1 })
  }

  def self.import(file)
    message = []

    transaction do
      destroy_all

      CSV.foreach(file.path, headers: true) do |row|
        talk = new
        talk.attributes = row.to_hash.slice(*updatable_attributes)
        unless talk.save
          message << "Error id: #{talk.id} - #{talk.errors.messages}"
        end
      end
      if message.size == 0
        message << "Talk CSVのインポートに成功しました"
      else
        raise ActiveRecord::Rollback 
      end
    end

    return message
  end

  def self.updatable_attributes
    [
      "id",
      "conference_id",
      "title",
      "abstract",
      "track_id",
      "talk_category_id",
      "talk_difficulty_id",
      "date",
      "conference_day_id",
      "start_time",
      "end_time",
      "movie_url",
      "show_on_timetable",
      "video_published",
      "document_url",
      "additional_documents"
    ]
  end

  def day
    return self.conference_day_id
  end

  def track_name
    track.present? ? track.name : ''
  end

  def slot_number
    SLOT_MAP.each_with_index do |time, index|
      if time > self.start_time.to_time.strftime("%H%M")
        return index.to_s
      end
    end
  end

  def talk_number
    return day.to_s + self.track.name + slot_number
  end

  def day_slot
    return self.day.to_s + "_" + self.slot_number
  end

  def row_start
    ((self.start_time.in_time_zone('Asia/Tokyo') - Time.zone.parse("2000-01-01 12:00")) / 60 / 5).to_i + 1
  end

  def row_end
    ((self.end_time - self.start_time).to_i / 60 / 5) + row_start
  end

  def self.find_by_params(day, slot_number_param, track_id)
    date = ConferenceDay.find(day.to_i).date

    after = Time.zone.parse(SLOT_MAP[slot_number_param.to_i - 1].dup.insert(2, ":")).utc.strftime("%T")
    before = (Time.zone.parse(SLOT_MAP[slot_number_param.to_i].dup.insert(2, ":")) - 60).utc.strftime("%T")

    where(date: date, track_id: track_id)
      .where("TIME(start_time) BETWEEN '#{after}' AND '#{before}'")
  end

  def speaker_names
    speakers.map(&:name)
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
    talk_time.present? ? talk_time.time_minutes : 0
  end

  def start_to_end
    if start_time.present? && end_time.present?
      start_time.strftime("%H:%M") + "-" + end_time.strftime("%H:%M")
    else
      ''
    end
  end

  def expected_participant_params
    self.expected_participants.filter_map do |e|
      ProposalItemConfig.find(e).params unless e == 0
    end
  end

  def execution_phase_params
    self.execution_phases.filter_map do |e|
      ProposalItemConfig.find(e).params unless e == 0
    end
  end

  def archived?
    now = Time.now.in_time_zone('Tokyo')
    etime =  DateTime.parse("#{date.strftime('%Y-%m-%d')} #{end_time.strftime('%H:%M')} +0900")
    return (now.to_i - etime.to_i) >= 600
  end

  def sponsor_session?
    sponsor.present?
  end

  private

  def validate_expected_participants
    errors.add(:base, '想定受講者は最低1項目選択してください') if expected_participants&.empty?
  end

  def validate_execution_phases
    errors.add(:base, '実行フェーズは最低1項目選択してください') if execution_phases&.empty?
  end
end
