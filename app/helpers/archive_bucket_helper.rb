# HarvestJob の出力先となるアーカイブ用 S3 バケットと、その配信用 CloudFront ドメイン
# EnvHelper の env_name に依存する
module ArchiveBucketHelper
  def archive_bucket_name
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

  def archive_cloudfront_domain_name(bucket_name)
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
