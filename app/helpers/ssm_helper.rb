require 'aws-sdk-ssm'

module SsmHelper
  def ssm_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::SSM::Client.new(region: 'us-east-1', credentials: creds)
    else
      Aws::SSM::Client.new(region: 'us-east-1')
    end
  end

  def create_parameter(name, value, tier = 'Standard', type = 'SecureString')
    tags = [{ key: 'Environment', value: env_name }]
    tags << { key: 'ReviewAppNumber', value: review_app_number.to_s } if ENV['DREAMKAST_NAMESPACE']

    ssm_client.put_parameter(
      {
        name:,
        value:,
        tier:,
        type:,
        tags:
      }
    )
  end

  def delete_parameter(name)
    ssm_client.delete_parameter(name:)
  end
end
