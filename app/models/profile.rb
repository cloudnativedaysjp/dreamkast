class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "はメールアドレスではありません")
    end
  end
end

class Profile < ApplicationRecord
  validates :sub, presence: true, uniqueness: true, length: { maximum: 250 }
  validates :email, presence: true, uniqueness: true, email: true
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :industry_id, presence: true, length: { maximum: 10 }
  validates :occupation, presence: true, length: { maximum: 50 }
  validates :company_name, presence: true, length: { maximum: 128 }
  validates :company_email, presence: true, email: true
  validates :department, presence: true, length: { maximum: 128 }
  validates :position, presence: true, length: { maximum: 128 }
end
