class SpeakerInvitationAcceptsController < ApplicationController
  include ValidatesInvitation
  include SecuredSpeaker
  before_action :set_speaker

  skip_before_action :logged_in_using_omniauth?, only: [:invite]

  def invite
    return redirect_to(new_speaker_invitation_accept_path(token: params[:token])) if from_auth0?(params)
    @conference = current_conference
    @speaker_invitation = SpeakerInvitation.find_by(conference_id: current_conference.id, token: params[:token])
  end

  def new
    @speaker_invitation_accept = SpeakerInvitationAccept.new
    @conference = current_conference

    @speaker_invitation = SpeakerInvitation.find_by(conference_id: current_conference.id, token: params[:token])
    unless @speaker_invitation
      raise(ActiveRecord::RecordNotFound)
    end

    reason = invalid_invitation_reason(@speaker_invitation, :speaker_invitation_accept)
    flash.now[:alert] = InvalidInvitation::MESSAGES[reason] if reason
    @talk = @speaker_invitation.talk
    @proposal = @talk.proposal
    user_id = current_user_model.id
    @speaker = if user_id && Speaker.where(user_id:, conference: @conference).exists?
                 Speaker.find_by(conference: @conference, user_id:)
               else
                 Speaker.new(conference: @conference, user_id:, email: current_user[:info][:email])
               end
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @conference = current_conference
        @speaker_invitation = find_valid_invitation!(SpeakerInvitation, params[:token], :speaker_invitation_accept, lock: true)

        speaker_param = speaker_invitation_accept_params.merge(conference: @conference, email: current_user[:info][:email])
        speaker_param.delete(:speaker_invitation_id)

        user_id = current_user_model.id
        @speaker = if user_id && Speaker.where(user_id:, conference: @conference).exists?
                     Speaker.find_by(conference: @conference, user_id:)
                   else
                     Speaker.new(conference: @conference, user_id:, email: current_user[:info][:email])
                   end
        @speaker.update!(speaker_param)
        @speaker.save!

        @talk = @speaker_invitation.talk
        @talk.speakers << @speaker
        @talk.save!

        @speaker_invitation_accept = SpeakerInvitationAccept.new(conference_id: @conference.id, speaker_invitation_id: @speaker_invitation.id, speaker_id: @speaker.id, talk_id: @talk.id)
        @speaker_invitation_accept.save!
        @speaker_invitation.update_columns(accepted_at: Time.current)


        redirect_to(speaker_dashboard_path(event: @conference.abbr), notice: 'Speaker was successfully added.')
      end
    rescue InvalidInvitation => e
      # ステータスは 403 のまま、理由を案内する画面を表示する
      flash.now[:alert] = e.message
      render(:new, status: :forbidden)
    rescue ActiveRecord::RecordInvalid => e
      render(:new, alert: e.message)
    end
  end

  def speaker_invitation_accept_params
    params.require(:speaker).permit(
      :speaker_invitation_id,
      :name,
      :name_mother_tongue,
      :profile,
      :company,
      :job_title,
      :twitter_id,
      :github_id,
      :avatar,
      :additional_documents
    )
  end

  def from_auth0?(params)
    params[:state].present?
  end
end
