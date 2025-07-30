class Streaming < ApplicationRecord
  before_create :set_uuid

  belongs_to :conference
  belongs_to :track
  has_one :media_package_v2_channel_group
  has_one :media_package_v2_channel
  has_one :media_package_v2_origin_endpoint
  has_one :media_package_channel
  has_one :media_package_origin_endpoint
  has_one :media_package_parameter
  has_one :media_live_channel
  has_one :media_live_input
  has_one :media_live_input_security_group

  STATUS_CREATING = 'creating'.freeze
  STATUS_CRTEATED = 'created'.freeze
  STATUS_DELETING = 'deleting'.freeze
  STATUS_DELETED  = 'deleted'.freeze

  def destination_url
    media_live_input&.destination_url
  end

  def playback_url
    media_package_v2_origin_endpoint&.playback_url
  end
end
