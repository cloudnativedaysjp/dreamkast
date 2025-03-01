class SponsorSpeakerInviteAcceptsController < ApplicationController
  include SecuredSponsor

  skip_before_action :logged_in_using_omniauth?, only: [:invite]

  def invite
    return redirect_to(new_sponsor_speaker_invite_accept_path(token: params[:token])) if from_auth0?(params)
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_speaker_invite = SponsorSpeakerInvite.find_by(token: params[:token])
  end

  def new
    @sponsor_contact_invite_accept = SponsorContactInviteAccept.new
    @conference = Conference.find_by(abbr: params[:event])

    @sponsor_speaker_invite = SponsorSpeakerInvite.find_by(token: params[:token])
    unless @sponsor_speaker_invite
      raise(ActiveRecord::RecordNotFound)
    end

    if Time.zone.now > @sponsor_speaker_invite.expires_at
      flash.now[:alert] = '招待メールが期限切れです。再度招待メールを送ってもらってください。'
    end
    @sponsor = @sponsor_speaker_invite.sponsor
    @sponsor_speaker = if Speaker.where(email: current_user[:info][:email], conference: @conference, sponsor: @sponsor).exists?
                         Speaker.find_by(email: current_user[:info][:email], conference: @conference, sponsor: @sponsor)
                       else
                         Speaker.new(email: current_user[:info][:email], conference: @conference, sponsor: @sponsor)
                       end
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @conference = Conference.find_by(abbr: params[:event])
        @sponsor_speaker_invite = SponsorSpeakerInvite.find(params[:speaker][:sponsor_speaker_invite_id])
        @sponsor = @sponsor_speaker_invite.sponsor

        speaker_param = sponsor_speaker_invite_accept_params.merge(conference: @conference, email: current_user[:info][:email])
        speaker_param.delete(:sponsor_speaker_invite_id)

        @sponsor_contact = if SponsorContact.where(email: current_user[:info][:email], conference: @conference).exists?
                             SponsorContact.find_by(conference: @conference, email: current_user[:info][:email])
                           else
                             SponsorContact.new(email: current_user[:info][:email], conference: @conference, sponsor: @sponsor)
                           end
        if @sponsor_contact.new_record?
          @sponsor_contact.update!(name: sponsor_speaker_invite_accept_params[:name])
          @sponsor_contact.save!
        end

        @sponsor_speaker = if Speaker.where(email: current_user[:info][:email], conference: @conference, sponsor: @sponsor).exists?
                             Speaker.find_by(conference: @conference, email: current_user[:info][:email])
                           else
                             Speaker.new(email: current_user[:info][:email], conference: @conference, sponsor: @sponsor)
                           end
        @sponsor_speaker.update!(speaker_param)
        @sponsor_speaker.save!

        @sponsor_speaker_invite_accept = SponsorSpeakerInviteAccept.new(
          conference: @conference,
          speaker: @sponsor_speaker,
          sponsor_contact: @sponsor_contact,
          sponsor_speaker_invite: @sponsor_speaker_invite,
          sponsor: @sponsor
        )
        @sponsor_speaker_invite_accept.save!

        redirect_to(sponsor_dashboards_path(event: @conference.abbr, sponsor_id: @sponsor.id), notice: 'Speaker was successfully added.')
      end
    rescue ActiveRecord::RecordInvalid => e
      p(e)
      render(:new, alert: e.message)
    end
  end

  def sponsor_speaker_invite_accept_params
    params.require(:speaker).permit(
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
      :sponsor_speaker_invite_id,
      :additional_documents,
      :sponsor_id
    )
  end

  def from_auth0?(params)
    params[:state].present?
  end
end
