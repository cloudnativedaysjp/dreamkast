namespace :aws do
  task delete_review_app_resources: :environment do
    include(MediaLiveHelper)
    include(EnvHelper)

    exit unless review_app?

    delete_media_live_channels_of_review_app(review_app_number)
    delete_media_live_inputs_of_review_app(review_app_number)
    delete_sqs(review_app_number)
  end

  def delete_sqs(review_app_number)
    cli = Aws::SQS::Client.new(region: 'ap-northeast-1')
    result = cli.get_queue_url({ queue_name: "review_app_#{review_app_number}" + '.fifo' })
    cli.delete_queue({ queue_url: result.queue_url })
  rescue Aws::SQS::Errors::NonExistentQueue
    Rails.logger.debug('The queue does not exist')
  end
end
