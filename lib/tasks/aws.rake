namespace :aws do
  task delete_review_app_resources: :environment do
    include(MediaLiveHelper)
    include(EnvHelper)

    exit unless review_app?

    delete_media_live_channels_of_review_app(review_app_number)
    delete_media_live_inputs_of_review_app(review_app_number)
    delete_ivs_channels_of_review_app(review_app_number)
    delete_sqs(review_app_number)
  end

  def ivs_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::IVS::Client.new(region: 'ap-northeast-1', credentials: creds)
    else
      Aws::IVS::Client.new(region: 'ap-northeast-1')
    end
  end

  def delete_ivs_channels_of_review_app(review_app_num)
    client = ivs_client

    channels = []
    next_token = ''
    loop do
      resp = client.list_channels(next_token: next_token)
      channels.concat(resp.channels)
      break unless resp.next_token
      next_token = resp.next_token
    end

    r = channels.select do |channel|
      channel.tags['Environment'] == 'review_app' && channel.tags['ReviewAppNumber'] == review_app_num.to_s
    end

    r.each do |channel|
      puts("#{ENV['DRY_RUN'] == 'false' ? '' : '[DRY_RUN] '}Delete IVS Channel: #{channel.arn} (#{channel.name})")
      if ENV['DRY_RUN'] == 'false'
        client.delete_channel(arn: channel.arn)
      end
    end
  end

  def delete_sqs(review_app_number)
    cli = Aws::SQS::Client.new(region: 'ap-northeast-1')
    result = cli.get_queue_url({ queue_name: "review_app_#{review_app_number}" + '.fifo' })
    cli.delete_queue({ queue_url: result.queue_url })
  rescue Aws::SQS::Errors::NonExistentQueue
    Rails.logger.debug('The queue does not exist')
  end
end
