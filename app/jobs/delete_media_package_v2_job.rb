class DeleteMediaPackageV2Job < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform DeleteMediaPackageV2Job')
    conference, channel_ids = args

    channel_ids.each do |channel_id|
      channel = MediaPackageV2Channel.find(channel_id)
      origin_endpoint = channel.origin_endpoint

      if origin_endpoint
        origin_endpoint.delete_aws_resource
        if origin_endpoint.exists_aws_resource?
          raise "Failed to delete origin_endpoint: #{origin_endpoint}"
        end
        origin_endpoint.destroy!
      end

      channel.delete_aws_resource
      if channel.exists_aws_resource?
        raise "Failed to delete channel: #{channel}"
      end
      channel.destroy!
    end

    channel_group = conference.media_package_v2_channel_group
    if channel_group.channels.size == 0
      channel_group.delete_aws_resource
      if channel_group.exists_aws_resource?
        raise "Failed to delete channel_group: #{channel_group}"
      end
      channel_group.destroy!
    end
  rescue => e
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))
  end
end
