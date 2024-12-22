class SponsorDashboards::SponsorContactsController < ApplicationController
  include SecuredSponsor

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  # GET :event/sponsor_dashboard/sponsor_contacts/new
  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])

    if logged_in?
      if current_user
        if SponsorContact.find_by(conference_id: @conference.id, email: current_user[:info][:email])
          redirect_to(sponsor_dashboards_path)
        end

        unless @sponsor.speaker_emails&.downcase&.include?(current_user[:info][:email].downcase)
          redirect_to("/#{@conference.abbr}/sponsor_dashboards/login", notice: 'ログインが許可されていません')
        end
      end
    else
      redirect_to(sponsor_dashboards_login_path)
    end

    @sponsor_contact = SponsorContact.new
  end

  # GET :event/sponsor_dashboard/sponsor_contacts/:id/edit
  def edit
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_contact = SponsorContact.find_by(conference_id: @conference.id, id: params[:id])
    @sponsor = @sponsor_contact.sponsor
    authorize(@sponsor_contact)
  end

  # POST :event/sponsor_dashboard/sponsor_contacts
  def create
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.where(conference_id: @conference.id).where('speaker_emails like(?)', "%#{current_user[:info][:email]}%").first
    if @sponsor
      @sponsor_contact = SponsorContact.new(sponsor_contact_params.merge(conference_id: @conference.id))
      @sponsor_contact.sub = current_user[:extra][:raw_info][:sub]

      @sponsor_contact.email = current_user[:info][:email]
      @sponsor_contact.sponsor_id = @sponsor.id

      respond_to do |format|
        if @sponsor_contact.save
          format.html { redirect_to("/#{@conference.abbr}/sponsor_dashboards/#{@sponsor.id}", notice: 'Speaker was successfully created.') }
        else
          format.html { render(:new) }
        end
      end
    else
      redirect_to("/#{@conference.abbr}/sponsor_dashboards", notice: 'ログインが許可されていません')
    end
  end

  # PATCH/PUT :event/sponsor_dashboard/speakers/1
  # PATCH/PUT :event/sponsor_dashboard/speakers/1.json
  def update
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_contact = SponsorContact.find_by(conference_id: @conference.id, id: params[:id])

    authorize(@sponsor_contact)

    respond_to do |format|
      if @sponsor_contact.update(sponsor_contact_params)
        format.html { redirect_to(sponsor_dashboards_path, notice: 'Speaker was successfully updated.') }
        format.json { render(:show, status: :ok, location: @speaker) }
      else
        format.html { render(:edit) }
        format.json { render(json: @speaker_form.errors, status: :unprocessable_entity) }
      end
    end
  end

  private

  helper_method :sponsor_url

  def sponsor_url
    case action_name
    when 'new'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/sponsor_contacts"
    when 'edit', 'update'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/sponsor_contacts/#{params[:id]}"
    end
  end

  def pundit_user
    if current_user
      SponsorContact.find_by(conference: @conference.id, email: current_user[:info][:email])
    end
  end

  def sponsor_contact_params
    params.require(:sponsor_contact).permit(:name,
                                            :sub,
                                            :email,
                                            :conference_id)
  end
end
