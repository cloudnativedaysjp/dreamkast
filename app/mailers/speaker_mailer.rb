class SpeakerMailer < ApplicationMailer
  default from: 'CloudNative Days 実行委員会 <noreply@mail.cloudnativedays.jp>'
  layout 'mailer'

  def video_uploaded(speaker, talk, video_registration)
    @speaker = speaker
    @talk = talk
    @video_registration = video_registration

    mail(to: speaker.email, subject: 'ビデオファイルの提出が完了しました')
  end

  def cfp_registered(speaker, talk)
    @speaker = speaker
    @talk = talk

    mail(to: speaker.email, subject: 'CFP を受け付けました')
  end
end
