module SecuredSponsorDashboard
  extend ActiveSupport::Concern
  include SecuredSponsor

  included do
    before_action :authorize_sponsor_access!
  end

  private

  def authorize_sponsor_access!
    return redirect_to(auth_login_path(origin: request.fullpath)) unless current_user_model

    @sponsor = current_conference.sponsors.find(params[:sponsor_id])
    @sponsor_contact = @sponsor.sponsor_contacts.find_by(user_id: current_user_model.id, conference_id: current_conference.id)
    head(:forbidden) unless @sponsor_contact
  end
end
