# == Schema Information
#
# Table name: form_items
#
#  id            :bigint           not null, primary key
#  attr          :string(255)
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#

class FormItem < ApplicationRecord
  belongs_to :conference

  has_many :form_values
  has_many :profiles, through: :form_values, source: :profile

  validates :name, presence: true
  validates :attr, presence: true
end
