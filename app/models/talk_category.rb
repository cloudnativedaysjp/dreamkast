# == Schema Information
#
# Table name: talk_categories
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#
# Indexes
#
#  index_talk_categories_on_conference_id  (conference_id)
#

class TalkCategory < ApplicationRecord
  has_one :talk
  belongs_to :conference
end
