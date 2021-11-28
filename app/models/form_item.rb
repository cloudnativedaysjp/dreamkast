# == Schema Information
#
# Table name: form_items
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#
class FormItem < ApplicationRecord
  belongs_to :conference
  has_many :agreements
  has_many :profiles, through: :agreements
end
