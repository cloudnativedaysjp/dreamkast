# == Schema Information
#
# Table name: form_items
#
#  id            :integer          not null, primary key
#  conference_id :integer
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  attr          :string(255)
#

class FormItem < ApplicationRecord
  belongs_to :conference

  has_many :form_values
  has_many :profiles, through: :form_values, source: :profile

  validates :name, presence: true
  validates :attr, presence: true
end
