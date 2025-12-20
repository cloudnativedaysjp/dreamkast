class SponsorContactInviteAcceptsController < ApplicationController
  include SecuredSponsor

  skip_before_action :logged_in_using_omniauth?, only: [:invite]

  def invite
    return redirect_to(new_sponsor_contact_invite_accept_path(token: params[:token])) if from_auth0?(params)
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_contact_invite = SponsorContactInvite.find_by(token: params[:token])
  end

  def new
    @sponsor_contact_invite_accept = SponsorContactInviteAccept.new
    @conference = Conference.find_by(abbr: params[:event])

    @sponsor_contact_invite = SponsorContactInvite.find_by(token: params[:token])
    unless @sponsor_contact_invite
      raise(ActiveRecord::RecordNotFound)
    end

    if Time.zone.now > @sponsor_contact_invite.expires_at
      flash.now[:alert] = '招待メールが期限切れです。再度招待メールを送ってもらってください。'
    end
    @sponsor = @sponsor_contact_invite.sponsor
    user_id = current_user_model.id
    # Check by email instead of user_id (consistent with create action)
    @sponsor_contact = if current_user && current_user[:info] && current_user[:info][:email] && @sponsor.sponsor_contacts.any? { |contact| contact.user&.email == current_user[:info][:email] }
                         @sponsor.sponsor_contacts.find { |contact| contact.user&.email == current_user[:info][:email] }
                       else
                         SponsorContact.new(conference: @conference, sponsor: @sponsor, user_id:, email: current_user[:info][:email])
                       end
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @conference = Conference.find_by(abbr: params[:event])
        @sponsor_contact_invite = SponsorContactInvite.find(params[:sponsor_contact][:sponsor_contact_invite_id])
        @sponsor = @sponsor_contact_invite.sponsor

        speaker_param = sponsor_contact_invite_accept_params.merge(conference: @conference, email: current_user[:info][:email])
        speaker_param.delete(:sponsor_contact_invite_id)

        user_id = current_user_model.id
        # Check by email instead of user_id (consistent with other controllers)
        @sponsor_contact = if current_user && current_user[:info] && current_user[:info][:email] && @sponsor.sponsor_contacts.any? { |contact| contact.user&.email == current_user[:info][:email] }
                             @sponsor.sponsor_contacts.find { |contact| contact.user&.email == current_user[:info][:email] }
                           else
                             SponsorContact.new(conference: @conference, sponsor: @sponsor, user_id:, email: current_user[:info][:email])
                           end
        @sponsor_contact.update!(speaker_param)
        @sponsor_contact.save!

        @sponsor_contact_invite_accept = SponsorContactInviteAccept.new(
          conference: @conference,
          sponsor_contact: @sponsor_contact,
          sponsor_contact_invite: @sponsor_contact_invite,
          sponsor: @sponsor
        )
        @sponsor_contact_invite_accept.save!

        redirect_to(sponsor_dashboards_path(event: @conference.abbr, sponsor_id: @sponsor.id), notice: 'Speaker was successfully added.')
      end
    rescue ActiveRecord::RecordInvalid => e
      p(e)
      render(:new, alert: e.message)
    end
  end

  def sponsor_contact_invite_accept_params
    params.require(:sponsor_contact).permit(
      :sponsor_contact_invite_id,
      :sponsor_id,
      :name
    )
  end

  def from_auth0?(params)
    params[:state].present?
  end
end
