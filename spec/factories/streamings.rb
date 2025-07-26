# == Schema Information
#
# Table name: streamings
#
#  id            :string(255)      not null, primary key
#  conference_id :integer          not null
#  track_id      :integer          not null
#  status        :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  error_cause   :text(65535)
#
# Indexes
#
#  index_streamings_on_conference_id               (conference_id)
#  index_streamings_on_conference_id_and_track_id  (conference_id,track_id) UNIQUE
#  index_streamings_on_track_id                    (track_id)
#

FactoryBot.define do
  factory :streaming, class: Streaming
end
