# == Schema Information
#
# Table name: form_items
#
#  id            :integer          not null, primary key
#  conference_id :integer
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class FormItem < ApplicationRecord
  belongs_to :conference
  has_many :agreements
  has_many :profiles, through: :agreements
end
