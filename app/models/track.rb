# == Schema Information
#
# Table name: tracks
#
#  id             :bigint           not null, primary key
#  name           :string(255)
#  number         :integer
#  video_platform :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :integer
#  room_id        :bigint           default(0)
#  video_id       :string(255)
#
# Indexes
#
#  index_tracks_on_conference_id  (conference_id)
#

class Track < ApplicationRecord
  has_many :talks
  has_one :live_stream_ivs
  has_one :live_stream_media_live
  has_one :media_package_channel
  has_one :media_package_v2_channel_group
  has_one :media_package_v2_channel
  has_one :media_package_v2_origin_endpoint
  has_one :streaming_aws_resource
  has_one :media_live_channel
  has_one :media_live_input
  has_one :media_live_input_security_group

  belongs_to :room, optional: true

  def on_air_talk
    on_air_talks = talks.includes(:video).map(&:video).select { |v| v && v.on_air }
    if on_air_talks.nil?
      return nil
    end
    if on_air_talks.size >= 2
      raise(Exception)
    end
    if on_air_talks.size == 0
      return nil
    end
    on_air_talks.first
  end
end
