class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "はメールアドレスではありません")
    end
  end
end

class TelValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[-+0-9]*\z/i
      record.errors[attribute] << (options[:message] || "は正しい電話番号ではありません")
    end
  end
end

class Profile < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :company_address_prefecture, :shortcuts => [:name]

  belongs_to :conference
  has_many :registered_talks
  has_many :talks, -> {order('conference_day_id ASC, start_time ASC')}, through: :registered_talks
  has_many :agreements
  has_many :form_items, through: :agreements
  has_many :chat_messages

  validate :sub_and_email_must_be_unique_in_a_conference, on: :create
  validates :sub, presence: true, length: { maximum: 250 }
  validates :email, presence: true, email: true
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :industry_id, presence: true, length: { maximum: 10 }
  validates :occupation, presence: true, length: { maximum: 50 }
  validates :company_name, presence: true, length: { maximum: 128 }
  validates :company_email, presence: true, email: true
  validates :company_address, presence: true, length: { maximum: 128 }
  validates :company_tel, presence: true, length: { maximum: 128 }, tel: true
  validates :department, presence: true, length: { maximum: 128 }
  validates :position, presence: true, length: { maximum: 128 }

  def sub_and_email_must_be_unique_in_a_conference
    if Profile.where(sub: sub, email: email, conference_id: conference_id).exists?
      errors.add(:email, ": #{conference.abbr.upcase}に既に同じメールアドレスで登録されています")
    end
  end

  def self.export(event_id)
    attr = %w[id email 名 姓 業種 職種 勤務先名/学校名 勤務先メールアドレス 勤務先都道府県 勤務先住所 勤務先電話番号 勤務先部署・所属/学部・学科・学年 勤務先役職]
    all = CSV.generate do |csv|
      csv << attr
      Profile.where(conference_id: event_id).each do |speaker|
        csv << [
          speaker.id,
          speaker.email,
          speaker.last_name,
          speaker.first_name,
          Industry.find(speaker.industry_id).name,
          speaker.occupation,
          speaker.company_name,
          speaker.company_email,
          speaker.company_address_prefecture_name,
          speaker.company_address,
          speaker.company_tel,
          speaker.department,
          speaker.position
        ]
      end
    end
    return all
  end
end
