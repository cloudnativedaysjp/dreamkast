# == Schema Information
#
# Table name: video_registrations
#
#  id         :integer          not null, primary key
#  talk_id    :integer          not null
#  url        :string(255)
#  status     :integer          default("0"), not null
#  statistics :json             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_video_registrations_on_talk_id  (talk_id)
#

class VideoRegistration < ApplicationRecord
  belongs_to :talk
  enum status: { unsubmitted: 0, submitted: 1, confirmed: 2, invalid_format: 3 }
  STATUS_MESSAGE = {
    'submitted' => '提出されたビデオファイルの確認中です。',
    'unsubmitted' =>  '未確認',
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
