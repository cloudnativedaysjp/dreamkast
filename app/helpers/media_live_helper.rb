module MediaLiveHelper
  def media_live_client
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    if creds.set?
      Aws::MediaLive::Client.new(region: 'us-east-1', credentials: creds)
    else
      Aws::MediaLive::Client.new(region: 'us-east-1')
    end
  end

  def get_media_live_inputs_from_aws(input_ids=[])
    inputs = []
    next_token = ''
    while true
      resp = media_live_client.list_inputs(next_token: next_token)
      inputs.concat(resp.inputs)
      break unless resp.next_token
      next_token = resp.next_token
    end

    inputs.select{ |input| input_ids.include?(input.id) }
  end

  def get_media_live_channels_from_aws(channel_ids=[])
    channels = []
    next_token = ''
    while true
      resp = media_live_client.list_channels(next_token: next_token)
      channels.concat(resp.channels)
      break unless resp.next_token
      next_token = resp.next_token
    end

    channels.select{ |channel| channel_ids.include?(channel.id) }
  end

  def wait_until(waiter_name, channel_id)
    media_live_client.wait_until(waiter_name, channel_id: channel_id) do |w|
      w.max_attempts = 30
      w.delay = 5
    end
  end
end