# == Schema Information
#
# Table name: video_registrations
#
#  id         :bigint           not null, primary key
#  statistics :json             not null
#  status     :integer          default("unsubmitted"), not null
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  talk_id    :bigint           not null
#
# Indexes
#
#  index_video_registrations_on_talk_id  (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (talk_id => talks.id)
#

class VideoRegistration < ApplicationRecord
  belongs_to :talk
  enum status: { unsubmitted: 0, submitted: 1, confirmed: 2, invalid_format: 3 }
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
