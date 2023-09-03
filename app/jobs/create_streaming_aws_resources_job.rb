class CreateStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include MediaPackageV2Helper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  attr_reader :conference
  attr_reader :track

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform CreateMediaPackageV2Job')
    @streaming_aws_resource = args[0]
    @conference = @streaming_aws_resource.conference
    @track = @streaming_aws_resource.track

    create_media_package_v2_resources(conference, track)
    create_media_package_resources(conference, track)
    # create_media_live_resources(conference, track)

    @streaming_aws_resource.update!(status: 'created')
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

  def create_media_package_v2_resources(conference, track)
    logger.info('Perform CreateMediaPackageV2Job')

    channel_group = MediaPackageV2ChannelGroup.find_by(conference_id: @conference.id, track_id: track.id, name: channel_group_name)
    unless channel_group.present?
      logger.info("creating channel group #{channel_group_name}...")
      channel_group = MediaPackageV2ChannelGroup.create!(conference_id: @conference.id, track_id: track.id, name: channel_group_name)
      logger.info("created channel group: #{channel_group.name}")
    end
    logger.info("channel group: #{channel_group}")
    channel_group.create_aws_resource

    channel = channel_group.channel
    unless channel.present?
      logger.info("creating channel #{channel_name}...")
      channel = MediaPackageV2Channel.create!(conference:, track:, media_package_v2_channel_group_id: channel_group.id, name: channel_name)
      logger.info("created channel: #{channel_group.name}")
    end
    logger.info("channel: #{channel}")
    channel.create_aws_resource

    origin_endpoint = channel.origin_endpoint
    unless origin_endpoint.present?
      logger.info("creating origin endpoint #{origin_endpoint_name}...")
      origin_endpoint = MediaPackageV2OriginEndpoint.create!(conference:, track:, media_package_v2_channel_id: channel.id, name: origin_endpoint_name)
      logger.info("created origin endpoint: #{origin_endpoint.name}")
    end
    logger.info("origin endpoint: #{origin_endpoint}")
    origin_endpoint.create_aws_resource
  end

  def create_media_package_resources(conference, track)
    logger.info('Perform CreateMediaPackageJob')

    channel= MediaPackageChannel.find_by(conference_id: @conference.id, track_id: track.id)
    unless channel.present?
      logger.info("creating media package channel group...")
      channel = MediaPackageChannel.create!(conference:, track:)
    end
    channel.create_media_package_resources

    parameter = MediaPackageParameter.find_by(conference_id: @conference.id, track_id: track.id)
    unless parameter.present?
      logger.info("creating media package parameter for password...")
      parameter = MediaPackageParameter.create!(conference:, track:, media_package_channel: channel)
    end
    parameter.create_aws_resources

    endpoint = MediaPackageOriginEndpoint.find_by(conference_id: @conference.id, media_package_channel_id: channel.id)
    unless endpoint.present?
      logger.info("creating media package origin endpoint group...")
      endpoint = MediaPackageOriginEndpoint.new(conference:, media_package_channel: channel)
    end
    endpoint.create_media_package_resources
  end

  def create_media_live_resources(conference, track)
    logger.info('Perform CreateMediaLiveJob')

    media_live = LiveStreamMediaLive.find_by(conference:, track:)
    unless media_live.present?
      logger.info("creating media live resources...")
      media_live = LiveStreamMediaLive.new(conference:, track:)
    end
    media_live.create_aws_resources

    logger.error("Failed to create LiveStreamMediaLive: #{media_live.errors}") unless media_live.save

    media_live.create_aws_resources
  end
end
