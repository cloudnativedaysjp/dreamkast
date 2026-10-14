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
end
