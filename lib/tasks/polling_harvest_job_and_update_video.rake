namespace :util do
  desc 'polling harvest job and update video'
  task polling_harvest_job_and_update_video: :environment do
    include EnvHelper
    include MediaPackageHelper

    client = media_package_client
    MediaPackageHarvestJob.where(status: 'IN_PROGRESS').each do |harvest_job|
      resp = client.describe_harvest_job(id: harvest_job.job_id)
      harvest_job.update!(status: resp.status)

      url = "https://#{cloudfront_domain_name(resp.s3_destination.bucket_name)}/#{resp.s3_destination.manifest_key}"
      if resp.status == 'SUCCEEDED' && harvest_job.talk.video_id == ''
        harvest_job.talk.video.update!(video_id: url)
      end
    end
  end

  def cloudfront_domain_name(bucket_name)
    case bucket_name
    when 'dreamkast-ivs-stream-archive-prd'
      'd3pun3ptcv21q4.cloudfront.net'
    when 'dreamkast-ivs-stream-archive-stg'
      'd3i2o0iduabu0p.cloudfront.net'
    else
      'd1jzp6sbtx9by.cloudfront.net'
    end
  end
end
