class SpeakerMailer < ApplicationMailer
  layout 'mailer'

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
