class SesEventPoller
  DEFAULT_WAIT_TIME = 10
  DEFAULT_MAX_MESSAGES = 10

  def initialize(queue_url:, wait_time: DEFAULT_WAIT_TIME, max_messages: DEFAULT_MAX_MESSAGES)
    @queue_url = queue_url
    @wait_time = wait_time
    @max_messages = max_messages
    @client = Aws::SQS::Client.new
  end

  def poll_once
    resp = @client.receive_message(
      queue_url: @queue_url,
      max_number_of_messages: @max_messages,
      wait_time_seconds: @wait_time
    )

    resp.messages.each do |message|
      SesEventProcessor.process(message.body)
      @client.delete_message(queue_url: @queue_url, receipt_handle: message.receipt_handle)
    end
  end
end
