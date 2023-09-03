# == Schema Information
#
# Table name: streaming_aws_resources
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
#  index_streaming_aws_resources_on_conference_id               (conference_id)
#  index_streaming_aws_resources_on_conference_id_and_track_id  (conference_id,track_id) UNIQUE
#  index_streaming_aws_resources_on_track_id                    (track_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (track_id => tracks.id)
#

class StreamingAwsResource < ApplicationRecord
  before_create :set_uuid

  belongs_to :conference
  belongs_to :track

  STATUS_CREATING = 'creating'.freeze
  STATUS_CRTEATED = 'created'.freeze
  STATUS_DELETING = 'deleting'.freeze
  STATUS_DELETED  = 'deleted'.freeze
end
