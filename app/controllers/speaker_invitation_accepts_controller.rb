class SpeakerInvitationAcceptsController < ApplicationController
  include SecuredSpeaker
  before_action :set_speaker

  skip_before_action :logged_in_using_omniauth?, only: [:invite]

  def invite
    return redirect_to(speaker_invitation_accepts_path) if from_auth0?(params)
    @conference = Conference.find_by(abbr: params[:event])
    @speaker_invitation = SpeakerInvitation.find_by(token: params[:token])
  end

  def new
    @speaker_invitation_accept = SpeakerInvitationAccept.new
    @conference = Conference.find_by(abbr: params[:event])

    @speaker_invitation = SpeakerInvitation.find_by(token: params[:token])
    unless @speaker_invitation
      raise(ActiveRecord::RecordNotFound)
    end

    if Time.zone.now > @speaker_invitation.expires_at
      flash.now[:alert] = '招待メールが期限切れです。再度招待メールを送ってもらってください。'
    end
    @talk = @speaker_invitation.talk
    @proposal = @talk.proposal
    @speaker = Speaker.new(conference: @conference, email: current_user[:info][:email], name: current_user[:info][:name])
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @conference = Conference.find_by(abbr: params[:event])
        @speaker_invitation = SpeakerInvitation.find(params[:speaker][:speaker_invitation_id])

        speaker_param = speaker_invitation_accept_params.merge(conference: @conference, email: current_user[:info][:email], name: current_user[:info][:name])
        speaker_param.delete(:speaker_invitation_id)

        @speaker = Speaker.new(speaker_param)
        @speaker.save!

        @talk = @speaker_invitation.talk
        @talk.speakers << @speaker
        @talk.save!

        @speaker_invitation_accept = SpeakerInvitationAccept.new(conference_id: @conference.id, speaker_invitation_id: @speaker_invitation.id, speaker_id: @speaker.id, talk_id: @talk.id)
        @speaker_invitation_accept.save!


        redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'Speaker was successfully added.')
      end
    rescue ActiveRecord::RecordInvalid => e
      render(:new, alert: e.message)
    end
  end

  def speaker_invitation_accept_params
    params.require(:speaker).permit(
      :speaker_invitation_id,
      :name,
      :name_mother_tongue,
      :sub,
      :email,
      :profile,
      :company,
      :job_title,
      :twitter_id,
      :github_id,
      :avatar,
      :conference_id,
      :additional_documents
    )
  end

  def from_auth0?(params)
    params[:state].present?
  end
end
