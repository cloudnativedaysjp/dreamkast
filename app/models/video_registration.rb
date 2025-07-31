class VideoRegistration < ApplicationRecord
  belongs_to :talk
  enum :status, { unsubmitted: 0, submitted: 1, confirmed: 2, invalid_format: 3 }
  STATUS_MESSAGE = {
    'submitted' => '提出されたビデオファイルの確認中です。',
    'unsubmitted' =>  '未確認 ※アップロードからステータス反映まで30分程度かかることがあります',
    'confirmed' =>  '確認済み',
    'invalid_format' =>  'フォーマットに問題あり'
  }.freeze

  def status_message
    STATUS_MESSAGE[status]
  end

  # TODO: ステータスが変化したときにメールを送る
  # def send_mail
  #   begin
  #     speaker = Speaker.find(talk.speaker_id)
  #     SpeakerMailer.video_uploaded(speaker, talk, @video_registration).deliver_later
  #   rescue => e
  #     logger.error("Failed to send mail: #{e.message}")
  #   end
  # end
end
