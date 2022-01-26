# == Schema Information
#
# Table name: viewer_counts
#
#  id            :integer          not null, primary key
#  conference_id :integer
#  track_id      :integer
#  stream_type   :string(255)
#  talk_id       :integer
#  count         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_viewer_counts_on_conference_id  (conference_id)
#  index_viewer_counts_on_talk_id        (talk_id)
#  index_viewer_counts_on_track_id       (track_id)
#

FactoryBot.define do
  factory :cndt2021_viewer_count, class: ViewerCount do
    conference_id { 4 }
    track_id { 11 }
    stream_type { 'IVS' }
    talk_id { 12 }
    count { 2 }
  end
end
