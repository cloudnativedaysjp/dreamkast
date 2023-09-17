class DeleteMediaPackageJob < ApplicationJob
  include LogoutHelper

  queue_as :default
  self.queue_adapter = :async

  def perform(*args)
    logger.info('Perform DeleteMediaPackageJob')
    channel = args[0]
    channel.media_package_origin_endpoints.each do |oe|
      oe.delete_aws_resource
      oe.destroy
    end
    channel.media_package_harvest_jobs.each(&:destroy)
    channel.delete_aws_resource
    channel.destroy
  rescue => e
    logger.error(e.message)
  end
end
