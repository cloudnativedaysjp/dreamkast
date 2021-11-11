class SpeakerMailer < ApplicationMailer
  default from: "CloudNative Days \u5B9F\u884C\u59D4\u54E1\u4F1A <noreply@mail.cloudnativedays.jp>"
  layout "mailer"

  def video_uploaded(speaker, talk, video_registration)
    @speaker = speaker
    @talk = talk
    @video_registration = video_registration

    mail(to: speaker.email, subject: "\u30D3\u30C7\u30AA\u30D5\u30A1\u30A4\u30EB\u306E\u63D0\u51FA\u304C\u5B8C\u4E86\u3057\u307E\u3057\u305F")
  end

  def cfp_registered(conference, speaker, talk)
    @conference = conference
    @speaker = speaker
    @talk = talk

    mail(to: speaker.email, subject: "【#{@conference.name}】プロポーザルを受け付けました")
  end
end
