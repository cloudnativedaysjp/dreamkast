# == Schema Information
#
# Table name: access_logs
#
#  id         :bigint           not null, primary key
#  ip         :string(255)
#  name       :string(255)
#  page       :string(255)
#  sub        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#

class AccessLog < ApplicationRecord
  belongs_to :profile
end
