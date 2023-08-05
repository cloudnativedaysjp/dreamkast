class CreateMediaPackageV2Job < ApplicationJob
  include EnvHelper
  include MediaPackageV2Helper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  attr_reader :conference, :track

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform CreateMediaPackageV2Job')
    @conference = args[0]
    tracks = @conference.tracks
    channel_group = MediaPackageV2ChannelGroup.find_by(conference_id: @conference.id, name: channel_group_name)
    unless channel_group.present?
      logger.info("creating channel group #{channel_group_name}...")
      channel_group = MediaPackageV2ChannelGroup.create!(conference_id: @conference.id, name: channel_group_name)
      logger.info("created channel group: #{channel_group.name}")
    end
    logger.info("channel group: #{channel_group}")
    channel_group.create_aws_resource

    tracks.each do |track|
      @track = track
      channel = channel_group.channels.find_by(track_id: track.id)
      unless channel.present?
        logger.info("creating channel #{channel_name}...")
        channel = MediaPackageV2Channel.create!(conference:, track:, media_package_v2_channel_group_id: channel_group.id, name: channel_name)
        logger.info("created channel: #{channel_group.name}")
      end
      logger.info("channel: #{channel}")
      channel.create_aws_resource
    end

    channel_group.channels.each do |channel|
      @track = channel.track
      origin_endpoint = channel.origin_endpoint
      if origin_endpoint.nil?
        logger.info("creating origin endpoint #{origin_endpoint_name}...")
        origin_endpoint = MediaPackageV2OriginEndpoint.create!(conference:, track:, media_package_v2_channel_id: channel.id, name: origin_endpoint_name)
        logger.info("created origin endpoint: #{origin_endpoint.name}")
      end
      logger.info("origin endpoint: #{origin_endpoint}")
      origin_endpoint.create_aws_resource
    end
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end
end
