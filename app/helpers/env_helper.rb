module EnvHelper
  def env_name
    case
    when ENV['REVIEW_APP'] == 'true'
      'review_app'
    when ENV['S3_BUCKET'] == 'dreamkast-stg-bucket'
      'staging'
    when ENV['S3_BUCKET'] == 'dreamkast-prd-bucket'
      'production'
    else
      'others'
    end
  end
end
