# == Schema Information
#
# Table name: streamings
#
#  id            :string(255)      not null, primary key
#  status        :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint           not null
#  track_id      :bigint           not null
#
# Indexes
#
#  index_streamings_on_conference_id               (conference_id)
#  index_streamings_on_conference_id_and_track_id  (conference_id,track_id) UNIQUE
#  index_streamings_on_track_id                    (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

FactoryBot.define do
  factory :media_package_v2_origin_endpoint, class: MediaPackageV2OriginEndpoint
end
