class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add(attribute, (options[:message] || 'はメールアドレスではありません'))
    end
  end
end

class TelValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[+0-9]*\z/i
      record.errors.add(attribute, (options[:message] || 'は正しい電話番号ではありません'))
    end
  end
end

class PostalCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A\d*\z/i
      record.errors.add(attribute, (options[:message] || 'は入力可能な郵便番号ではありません。ハイフンで区切らずに入力してください。'))
    end
  end
end

class Profile < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to_active_hash :company_name_prefix, shortcuts: [:name], class_name: '::FormModels::CompanyNamePrefix'
  belongs_to_active_hash :company_name_suffix, shortcuts: [:name], class_name: '::FormModels::CompanyNameSuffix'

  belongs_to :conference
  belongs_to :user
  has_many :registered_talks
  has_many :talks, -> { order('conference_day_id ASC, start_time ASC') }, through: :registered_talks
  has_many :form_values
  has_many :form_items, through: :form_values, source: :form_item
  has_many :chat_messages
  has_many :check_ins
  has_many :session_questions, dependent: :destroy
  has_many :session_question_votes, dependent: :destroy
  has_many :check_in_conferences, dependent: :destroy
  has_many :check_in_talks
  has_many :stamp_rally_check_ins
  has_one :public_profile, dependent: :destroy
  accepts_nested_attributes_for :form_items

  before_validation :ensure_user, on: :create

  before_create do
    self.calendar_unique_code = SecureRandom.uuid
  end

  validate :sub_and_email_must_be_unique_in_a_conference, on: :create
  validates :user_id, uniqueness: { scope: :conference_id }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :industry_id, length: { maximum: 10 }
  validates :occupation_id, presence: false, length: { maximum: 50 }
  validates :company_name, presence: true, length: { maximum: 128 }
  validates :company_email, presence: true, email: true
  validates :company_postal_code, presence: true, length: { maximum: 8 }, postal_code: true
  validates :company_address_level1, presence: true, length: { maximum: 256 }
  validates :company_address_level2, presence: true, length: { maximum: 1024 }
  validates :company_address_line1, presence: true, length: { maximum: 1024 }
  validates :company_address_line2, presence: false, length: { maximum: 1024 }
  validates :company_tel, presence: true, length: { maximum: 128 }, tel: true
  validates :company_fax, presence: false, length: { maximum: 128 }
  validates :department, presence: true, length: { maximum: 128 }
  validates :position, presence: true, length: { maximum: 128 }
  validates :participation, presence: true
  validates :number_of_employee_id, length: { maximum: 128 }
  validates :annual_sales_id, length: { maximum: 128 }

  enum :participation, {
    online: 'オンライン参加',
    offline: '現地参加'
  }

  # userのsubとemailを委譲（userがnilの可能性がある場合はallow_nil: true）
  delegate :sub, :email, to: :user, allow_nil: true

  # 一時的な属性（before_validationでuserを作成するために使用）
  attr_accessor :pending_sub, :pending_email

  def sub_and_email_must_be_unique_in_a_conference
    if Profile.where(user_id:, conference_id:).exists?
      errors.add(:email, ": #{conference.abbr.upcase}に既に同じメールアドレスで登録されています")
    end
  end

  # 既存コードとの互換性のため、セッターを提供
  def sub=(value)
    if user_id.present?
      user.update!(sub: value)
    else
      self.pending_sub = value
    end
  end

  def email=(value)
    if user_id.present?
      user.update!(email: value)
    else
      self.pending_email = value
    end
  end

  def self.export(event_id)
    attr = %w[id email 姓 名 セイ メイ 業種 職種 勤務先名/所属団体 郵便番号 都道府県 勤務先住所1（都道府県以下） 勤務先住所2（ビル名） 電話番号 メールアドレス 参加方法]
    CSV.generate do |csv|
      csv << attr
      Profile.where(conference_id: event_id).each do |profile|
        csv << [
          profile.id,
          profile.email,
          profile.last_name,
          profile.first_name,
          profile.last_name_kana,
          profile.first_name_kana,
          profile.industry_name,
          profile.occupation,
          profile.company_full_name,
          profile.company_postal_code,
          profile.company_address_level1,
          profile.company_address_level2.to_s + profile.company_address_line1.to_s,
          profile.company_address_line2,
          profile.company_tel,
          profile.company_email,
          Profile.participations[profile.participation]
        ]
      end
    end
  end

  def gen_calendar_unique_code
    update!(calendar_unique_code: SecureRandom.uuid)
  end

  def qrcode_image
    Base64.strict_encode64(RQRCode::QRCode.new([{ data: JSON.dump({ profile_id: id }), mode: :byte_8bit }]).as_png.to_s)
  end

  def export_ics
    cal = Icalendar::Calendar.new
    filename = Rails.root.join('tmp', "#{calendar_unique_code}.ics").to_s
    talks.each { |t| cal.events << t.calendar }
    File.open(filename, 'w') do |f|
      f.write(cal.to_ical.to_s)
    end
    filename
  end

  def industry_name
    if industry_id.present?
      FormModels::Industry.all.map { |i| i.attributes[:child] }.flatten.find { |i| i.id == industry_id }.name
    else
      ''
    end
  end

  def company_full_name
    "#{company_name_prefix&.name}#{company_name}#{company_name_suffix&.name}"
  end

  def way_to_attend
    participation_before_type_cast
  end

  def attend_offline?
    offline?
  end

  def attend_online?
    online?
  end

  private

  def ensure_user
    return if user_id.present?

    sub_value = pending_sub
    email_value = pending_email

    if sub_value.present? && email_value.present?
      self.user = User.find_or_create_by!(sub: sub_value) do |u|
        u.email = email_value
      end
      # emailが指定されていて、Userのemailが異なる場合は更新
      if user.email != email_value
        user.update!(email: email_value)
      end
    else
      errors.add(:base, 'subとemailの両方が必要です')
    end
  end
end
