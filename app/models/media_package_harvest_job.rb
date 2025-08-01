class MediaPackageHarvestJob < ApplicationRecord
  include MediaPackageHelper
  include EnvHelper

  belongs_to :conference
  belongs_to :media_package_channel
  belongs_to :talk

  def job
    @job ||= media_package_client.describe_harvest_job(id: job_id) if job_id
  end

  def create_media_package_resources
    resp = media_package_client.create_harvest_job(create_params)
    resp = media_package_client.describe_harvest_job(id: resp.id)
    update!(job_id: resp.id, status: resp.status)
  end

  def video_url
    "https://#{cloudfront_domain_name(job.s3_destination.bucket_name)}/#{job.s3_destination.manifest_key}"
  end

  private

  def create_params
    {
      id: "#{resource_name}_#{id}",
      start_time: start_time.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      end_time: end_time.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      origin_endpoint_id: resource_name,
      s3_destination: {
        bucket_name:,
        manifest_key:,
        role_arn: 'arn:aws:iam::607167088920:role/MediaPackageLivetoVOD-Policy'
      }
    }
  end

  def manifest_key
    "mediapackage/#{conference.abbr}/talks/#{talk_id}/#{id}/playlist.m3u8"
  end

  def resource_name
    track = media_package_channel.streaming.track
    if review_app?
      "review_app_#{review_app_number}_#{conference.abbr}_track#{track.name}"
    else
      "#{env_name}_#{conference.abbr}_track#{track.name}"
    end
  end

  def bucket_name
    case AWS_LIVE_STREAM_REGION
    when 'us-east-1'
      case env_name
      when 'production'
        'dreamkast-ivs-stream-archive-prd'
      when 'staging'
        'dreamkast-ivs-stream-archive-stg'
      else
        'dreamkast-ivs-stream-archive-dev'
      end
    when 'us-west-2'
      case env_name
      when 'production'
        'dreamkast-archive-prd-us-west-2'
      when 'staging'
        'dreamkast-archive-stg-us-west-2'
      else
        'dreamkast-archive-dev-us-west-2'
      end
    end
  end

  def cloudfront_domain_name(bucket_name)
    case AWS_LIVE_STREAM_REGION
    when 'us-east-1'
      case bucket_name
      when 'dreamkast-ivs-stream-archive-prd'
        'd3pun3ptcv21q4.cloudfront.net'
      when 'dreamkast-ivs-stream-archive-stg'
        'd3i2o0iduabu0p.cloudfront.net'
      else
        'd1jzp6sbtx9by.cloudfront.net'
      end
    when 'us-west-2'
      case bucket_name
      when 'dreamkast-archive-prd-us-west-2'
        'd3pun3ptcv21q4.cloudfront.net'
      when 'dreamkast-archive-stg-us-west-2'
        'd3i2o0iduabu0p.cloudfront.net'
      else
        'd1jzp6sbtx9by.cloudfront.net'
      end
    end
  end
end
