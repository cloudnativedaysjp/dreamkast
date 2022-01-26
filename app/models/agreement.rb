# == Schema Information
#
# Table name: agreements
#
#  id           :integer          not null, primary key
#  profile_id   :integer
#  form_item_id :integer
#  value        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Agreement < ApplicationRecord
  belongs_to :profile
  belongs_to :form_item
end
