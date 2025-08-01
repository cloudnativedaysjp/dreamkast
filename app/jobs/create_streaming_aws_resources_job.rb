class CreateStreamingAwsResourcesJob < ApplicationJob
  include EnvHelper
  include MediaPackageV2Helper

  # queue_as :default
  self.queue_adapter = :async unless Rails.env.test?

  attr_reader :conference
  attr_reader :track
  attr_reader :streaming

  def perform(*args)
    # Rails.logger.level = Logger::DEBUG
    logger.info('Perform CreateMediaPackageV2Job')
    @streaming = args[0]
    @conference = @streaming.conference
    @track = @streaming.track

    @streaming.update!(error_cause: '', status: 'creating')

    create_media_package_v2_resources
    create_media_package_resources
    create_media_live_resources

    @streaming.update!(status: 'created')
    @streaming.update!(error_cause: '')
  rescue => e
    @streaming.update!(status: 'error', error_cause: e.message)
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end

  def create_media_package_v2_resources
    logger.info('Perform CreateMediaPackageV2Job')


    channel_group = MediaPackageV2ChannelGroup.find_or_create_by(streaming_id: @streaming.id, name: channel_group_name)
    logger.info("channel group: #{channel_group}")
    channel_group.create_aws_resource

    channel = MediaPackageV2Channel.find_or_create_by(streaming_id: @streaming.id, media_package_v2_channel_group_id: channel_group.id, name: channel_name)
    logger.info("channel: #{channel}")
    channel.create_aws_resource

    origin_endpoint = MediaPackageV2OriginEndpoint.find_or_create_by(streaming_id: @streaming.id, media_package_v2_channel_id: channel.id, name: origin_endpoint_name)
    logger.info("origin endpoint: #{origin_endpoint}")
    origin_endpoint.create_aws_resource

    origin_endpoint.add_origin_and_behavior
    logger.info('add origin and behavior to CloudFront distribution.')
  end

  def create_media_package_resources
    logger.info('Perform CreateMediaPackageJob')

    channel = MediaPackageChannel.find_or_create_by(streaming_id: @streaming.id)
    logger.info("channel: #{channel}")
    channel.create_aws_resource

    parameter = MediaPackageParameter.find_or_create_by(streaming_id: @streaming.id, media_package_channel_id: channel.id)
    logger.info("parameter: #{parameter}")
    parameter.create_aws_resources

    endpoint = MediaPackageOriginEndpoint.find_or_create_by(streaming_id: @streaming.id, media_package_channel_id: channel.id)
    logger.info("endpoint: #{endpoint}")
    endpoint.create_aws_resource
  end

  def create_media_live_resources
    logger.info('Perform CreateMediaLiveJob')

    MediaPackageParameter.find_by(streaming_id: @streaming.id)

    input_security_group = MediaLiveInputSecurityGroup.find_or_create_by(streaming_id: @streaming.id)
    logger.info("input_security_group: #{input_security_group}")
    input_security_group.create_aws_resources

    input = MediaLiveInput.find_or_create_by(streaming_id: @streaming.id, media_live_input_security_group_id: input_security_group.id)
    logger.info("input: #{input}")
    input.create_aws_resource

    channel = MediaLiveChannel.find_or_create_by(streaming_id: @streaming.id, media_live_input_id: input.id)
    logger.info("channel: #{channel}")
    channel.create_aws_resource
  end
end
