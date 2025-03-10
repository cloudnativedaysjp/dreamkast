module EnvHelper
  def env_name
    if ENV['REVIEW_APP'] == 'true'
      'review_app'
    elsif ENV['S3_BUCKET'] == 'dreamkast-stg-bucket'
      'staging'
    elsif ENV['S3_BUCKET'] == 'dreamkast-prod-bucket'
      'production'
    else
      'others'
    end
  end

  def review_app_number
    m = ENV['DREAMKAST_NAMESPACE'].match(/dreamkast-dev-dk-(.*)-dk/)
    if m
      m[1].to_i
    else
      0
    end
  end

  def review_app?
    env_name == 'review_app'
  end
end
