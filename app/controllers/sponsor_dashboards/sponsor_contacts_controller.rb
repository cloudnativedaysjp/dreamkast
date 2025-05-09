class SponsorDashboards::SponsorContactsController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  def index
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_contacts = @sponsor.sponsor_contacts
    @sponsor_contact_invites = @sponsor.sponsor_contact_invites
                                       .reject { |invite| invite.sponsor_contact_invite_accepts.present? }
                                       .group_by(&:email)
                                       .values
                                       .map { |invites| invites.max_by(&:expires_at) }
  end

  # GET :event/sponsor_dashboard/sponsor_contacts/new
  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])

    if logged_in?
      if current_user && SponsorContact.find_by(conference_id: @conference.id, email: current_user[:info][:email])
        redirect_to(sponsor_dashboards_path)
      end
    else
      redirect_to(auth_login_path(origin: request.fullpath))
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
    @sponsor = Sponsor.find(params[:sponsor_id])
    if @sponsor.sponsor_contacts.any? { |contact| contact.email == current_user[:info][:email] }
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

  def destroy
    @sponsor_contact = SponsorContact.find(params[:id])

    if @sponsor_contact.destroy
      flash.now[:notice] = "スポンサー担当者 #{@sponsor_contact.email} を削除しました"
    else
      flash.now[:alert] = "スポンサー担当者 #{@sponsor_contact.email} の削除に失敗しました"
      render(:index, status: :unprocessable_entity)
    end
  end

  private

  helper_method :sponsor_url, :turbo_stream_flash

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

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end

  def set_sponsor_contact
    @conference ||= Conference.find_by(abbr: params[:event])
    if current_user
      @sponsor_contact = SponsorContact.find_by(conference_id: @conference.id, email: current_user[:info][:email])
    end
  end
end
