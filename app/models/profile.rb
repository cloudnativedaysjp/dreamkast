# == Schema Information
#
# Table name: profiles
#
#  id                            :bigint           not null, primary key
#  calendar_unique_code          :string(255)
#  company_address               :string(255)
#  company_address_level1        :string(255)
#  company_address_level2        :string(255)
#  company_address_line1         :string(255)
#  company_address_line2         :string(255)
#  company_email                 :string(255)
#  company_fax                   :string(255)
#  company_name                  :string(255)
#  company_postal_code           :string(255)
#  company_tel                   :string(255)
#  department                    :string(255)
#  email                         :string(255)
#  first_name                    :string(255)
#  first_name_kana               :string(255)
#  last_name                     :string(255)
#  last_name_kana                :string(255)
#  occupation                    :string(255)
#  position                      :string(255)
#  sub                           :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  annual_sales_id               :integer          default(11)
#  company_address_prefecture_id :string(255)
#  company_name_prefix_id        :string(255)
#  company_name_suffix_id        :string(255)
#  conference_id                 :integer
#  industry_id                   :integer
#  number_of_employee_id         :integer          default(12)
#  occupation_id                 :integer          default(34)
#

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
  has_many :registered_talks
  has_many :talks, -> { order('conference_day_id ASC, start_time ASC') }, through: :registered_talks
  has_many :agreements
  has_many :form_items, through: :agreements
  has_many :chat_messages
  has_many :orders
  has_many :check_ins
  has_one :public_profile, dependent: :destroy

  before_create do
    self.calendar_unique_code = SecureRandom.uuid
  end

  validate :sub_and_email_must_be_unique_in_a_conference, on: :create
  validates :sub, presence: true, length: { maximum: 250 }
  validates :email, presence: true, email: true
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
  validates :number_of_employee_id, length: { maximum: 128 }
  validates :annual_sales_id, length: { maximum: 128 }

  def sub_and_email_must_be_unique_in_a_conference
    if Profile.where(sub:, email:, conference_id:).exists?
      errors.add(:email, ": #{conference.abbr.upcase}に既に同じメールアドレスで登録されています")
    end
  end

  def self.export(event_id)
    attr = %w[id email 姓 名 セイ メイ 業種 職種 勤務先名/所属団体 郵便番号 都道府県 勤務先住所1（都道府県以下） 勤務先住所2（ビル名） 電話番号 メールアドレス]
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
          profile.company_email
        ]
      end
    end
  end

  def gen_calendar_unique_code
    update!(calendar_unique_code: SecureRandom.uuid)
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

  def active_order
    orders.find { |order| order.cancel_order.nil? }
  end

  def way_to_attend
    active_order.tickets.first.title
  end

  def attend_offline?
    if active_order.present?
      active_order.tickets.first.title == '現地参加'
    else
      false
    end
  end

  def attend_online?
    if active_order.present?
      active_order.tickets.first.title == 'オンライン参加'
    else
      false
    end
  end
end
