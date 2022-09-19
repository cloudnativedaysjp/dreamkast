# == Schema Information
#
# Table name: agreements
#
#  id           :bigint           not null, primary key
#  value        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  form_item_id :integer
#  profile_id   :integer
#

class Agreement < ApplicationRecord
  belongs_to :profile
  belongs_to :form_item
end
