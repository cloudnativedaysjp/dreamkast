module MediaLiveHelper
  def media_live_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::MediaLive::Client.new(region: 'us-east-1', credentials: creds)
    else
      Aws::MediaLive::Client.new(region: 'us-east-1')
    end
  end

  def get_media_live_inputs_from_aws(input_ids = [])
    inputs = []
    next_token = ''
    while true
      resp = media_live_client.list_inputs(next_token: next_token)
      inputs.concat(resp.inputs)
      break unless resp.next_token
      next_token = resp.next_token
    end

    inputs.select { |input| input_ids.include?(input.id) }
  end

  def get_media_live_channels_from_aws(channel_ids = [])
    channels = []
    next_token = ''
    while true
      resp = media_live_client.list_channels(next_token: next_token)
      channels.concat(resp.channels)
      break unless resp.next_token
      next_token = resp.next_token
    end

    channels.select { |channel| channel_ids.include?(channel.id) }
  end

  def wait_channel_until(waiter_name, channel_id)
    media_live_client.wait_until(waiter_name, channel_id: channel_id) do |w|
      w.max_attempts = 30
      w.delay = 5
    end
  end

  def wait_input_until(waiter_name, input_id)
    media_live_client.wait_until(waiter_name, input_id: input_id) do |w|
      w.max_attempts = 30
      w.delay = 5
    end
  end

  def delete_media_live_channels_of_review_app(review_app_num)
    client = media_live_client

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
      puts("#{ENV['DRY_RUN'] == 'false' ? '' : '[DRY_RUN] '}Delete MediaLive Channel: #{channel.id} (#{channel.name})")
      if ENV['DRY_RUN'] == 'false'
        client.delete_channel(channel_id: channel.id)
      end
    end
  end

  def delete_media_live_inputs_of_review_app(review_app_num)
    client = media_live_client

    inputs = []
    next_token = ''
    while true
      resp = client.list_inputs(next_token: next_token)
      inputs.concat(resp.inputs)
      break unless resp.next_token
      next_token = resp.next_token
    end

    r = inputs.select do |input|
      input.tags['Environment'] == 'review_app' && input.tags['ReviewAppNumber'] == review_app_num.to_s
    end

    r.each do |input|
      puts("#{ENV['DRY_RUN'] == 'false' ? '' : '[DRY_RUN] '}Delete MediaLive Input: #{input.id} (#{input.name})")
      next unless ENV['DRY_RUN'] == 'false'
      client.wait_until(:input_detached, input_id: input.id) do |w|
        w.max_attempts = 30
        w.delay = 5
      end
      client.delete_input(input_id: input.id)
    end
  end
end
