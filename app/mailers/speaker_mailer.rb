class SpeakerMailer < ApplicationMailer
  default from: 'CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>'
  layout 'mailer'

  def video_uploaded(speaker, talk, video)
    @speaker = speaker
    @talk = talk
    @video = video

    mail(to: speaker.email, subject: 'ビデオファイルの提出が完了しました')
  end
end
