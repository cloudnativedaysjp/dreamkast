# == Schema Information
#
# Table name: rooms
#
#  id              :bigint           not null, primary key
#  description     :text(65535)
#  name            :string(255)      not null
#  number_of_seats :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  conference_id   :bigint           not null
#
# Indexes
#
#  index_rooms_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class Room < ApplicationRecord
  belongs_to :conference
  has_one :track
end
