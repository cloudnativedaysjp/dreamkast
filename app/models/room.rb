# == Schema Information
#
# Table name: rooms
#
#  id              :bigint           not null, primary key
#  description     :text(65535)      not null
#  integer         :integer          default(0), not null
#  name            :string(255)      not null
#  number_of_seats :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  conference_id   :bigint           not null
#  track_id        :bigint
#
# Indexes
#
#  index_rooms_on_conference_id  (conference_id)
#  index_rooms_on_track_id       (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

class Room < ApplicationRecord
  belongs_to :conference
  has_one :track
end
