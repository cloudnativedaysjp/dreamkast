class SpeakerMailer < ApplicationMailer
  layout 'mailer'

  def video_uploaded(speaker, talk, video_registration)
    @speaker = speaker
    @talk = talk
    @video_registration = video_registration

    mail(to: speaker.email, subject: 'ビデオファイルの提出が完了しました')
  end

  def cfp_registered(conference, speaker, talk)
    @conference = conference
    @speaker = speaker
    @talk = talk

    mail(to: speaker.email, subject: "【#{@conference.name}】プロポーザルを受け付けました")
  end

  def inform_speaker_announcement(conference, speaker)
    @conference = conference
    @speaker = speaker

    mail(
      to: @speaker.email,
      subject: "#{@conference.name}からのお知らせ"
    )
  end
end
