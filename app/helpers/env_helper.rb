module EnvHelper
  def env_name
    if ENV['REVIEW_APP'] == 'true'
      'review_app'
    elsif ENV['S3_BUCKET'] == 'dreamkast-stg-bucket'
      'staging'
    elsif ENV['S3_BUCKET'] == 'dreamkast-prd-bucket'
      'production'
    else
      'others'
    end
  end

  def review_app_number
    ENV['DREAMKAST_NAMESPACE'].gsub(/dreamkast-dk-/, '').to_i
  end

  def review_app?
    env_name == 'review_app'
  end

  def bucket_name
    case env_name
    when 'production'
      'dreamkast-ivs-stream-archive-prd'
    when 'staging'
      'dreamkast-ivs-stream-archive-stg'
    when 'review_app'
      'dreamkast-ivs-stream-archive-dev'
    else
      'dreamkast-ivs-stream-archive-dev'
    end
  end
end
