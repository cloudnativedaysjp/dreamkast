class MediaPackageChannel < ApplicationRecord
  include MediaPackageHelper
  include EnvHelper

  before_destroy :delete_aws_resource

  belongs_to :streaming
  has_many :media_package_origin_endpoints
  has_many :media_package_harvest_jobs

  def aws_resource
    @channel ||= media_package_client.describe_channel(id: channel_id) if channel_id
  end

  def ingest_endpoints
    aws_resource.dig('hls_ingest', 'ingest_endpoints')
  end

  def ingest_endpoint_url
    ingest_endpoints[0]['url']
  end

  def ingest_endpoint_username
    ingest_endpoints[0]['username']
  end

  def ingest_endpoint_password
    ingest_endpoints[0]['password']
  end

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_client.create_channel(create_channel_params)
      update!(channel_id: resp.id)
    end
  end

  def exists_aws_resource?
    media_package_client.describe_channel(id: channel_id)
    true
  rescue Aws::MediaPackage::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message.to_s)
    false
  end

  def delete_aws_resource
    media_package_client.delete_channel(id: channel_id) if exists_aws_resource?
  end

  private

  def create_channel_params
    {
      id: resource_name,
      description: '',
      tags:
    }
  end

  def tags
    tags = { 'Environment' => env_name }
    tags['ReviewAppNumber'] = review_app_number.to_s if ENV['DREAMKAST_NAMESPACE']
    tags
  end
end
