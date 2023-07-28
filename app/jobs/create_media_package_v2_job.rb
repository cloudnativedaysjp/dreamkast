class CreateMediaPackageV2Job < ApplicationJob
  include EnvHelper
  include LogoutHelper

  # queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform CreateMediaPackageV2Job')
    conference, track = args
    resource_name = if review_app?
                      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
                    else
                      "#{env_name}_#{conference.abbr}_track#{track.name}"
                    end

    p(channel_group = MediaPackageV2ChannelGroup.find_by(conference:, track:, name: resource_name))
    unless channel_group.present?
      logger.info("creating channel group #{resource_name}...")
      channel_group = MediaPackageV2ChannelGroup.new(conference:, track:, name: resource_name)
      logger.error("Failed to create MediaPackageV2ChannelGroup: #{channel_group.errors}") unless channel_group.save
      channel_group.ensure_resource
      logger.info("created channel group: #{channel_group.name}")
    end
    logger.info("channel group: #{channel_group}")

    channel = channel_group.channel
    unless channel.present?
      logger.info("creating channel #{resource_name}...")
      channel = MediaPackageV2Channel.new(conference:, track:, media_package_v2_channel_group_id: channel_group.id, name: resource_name)
      unless channel_group.save
        channel.errors.each do |error|
          logger.error("Failed to create MediaPackageV2Channel: #{error}")
        end
      end
      channel.create_resource
      logger.info("created channel: #{channel_group.name}")
    end
    logger.info("channel: #{channel}")

    origin_endpoint = channel.origin_endpoint
    if origin_endpoint&.empty?
      logger.info("creating origin endpoint #{resource_name}...")
      origin_endpoint = MediaPackageV2OriginEndpoint.new(conference:, track:, media_package_v2_channel_group_id: channel_group.id, media_package_v2_channel_id: channel.id, name: resource_name)
      logger.error("Failed to create MediaPackageV2Channel: #{origin_endpoint.errors}") unless origin_endpoint.save
      origin_endpoint.ensure_resource
      logger.info("created origin endpoint: #{origin_endpoint.name}")
    end
    logger.info("origin endpoint: #{origin_endpoint}")
  rescue => e
    logger.error(e.message)
  end
end
