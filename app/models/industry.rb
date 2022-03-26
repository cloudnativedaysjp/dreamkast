# == Schema Information
#
# Table name: industries
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#

class Industry < ApplicationRecord
end
