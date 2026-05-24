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
    namespace = ENV['DREAMKAST_NAMESPACE'].to_s
    m = namespace.match(/dreamkast-dev-dk-(.*)-dk/) || namespace.match(/dreamkast-dev-dk-(.*)-fifo-worker/)
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
