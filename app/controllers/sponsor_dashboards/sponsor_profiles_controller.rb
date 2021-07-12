class SponsorDashboards::SponsorProfilesController < ApplicationController
  include SecuredSponsor

  skip_before_action :logged_in_using_omniauth?, only: [:new]

  # GET :event/sponsor_dashboard/sponsor_profiles/new
  def new
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id])

    unless logged_in?
      redirect_to sponsor_dashboards_login_path
    else
      if set_current_user
        if SponsorProfile.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
          redirect_to sponsor_dashboards_path
        end

        unless @sponsor.speaker_emails&.include?(@current_user[:info][:email])
          redirect_to "/#{@conference.abbr}/sponsor_dashboards/login", notice: 'ログインが許可されていません'
        end
      end
    end

    @sponsor_profile = SponsorProfile.new
  end

  # GET :event/sponsor_dashboard/sponsor_profiles/:id/edit
  def edit
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor_profile = SponsorProfile.find_by(conference_id: @conference.id, id: params[:id])
    authorize @sponsor_profile
  end

  # POST :event/sponsor_dashboard/sponsor_profiles
  def create
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.where(conference_id: @conference.id).where('speaker_emails like(?)', "%#{@current_user[:info][:email]}%").first
    unless @sponsor
      redirect_to "/#{@conference.abbr}/sponsor_dashboards", notice: 'ログインが許可されていません'
    else
      @sponsor_profile = SponsorProfile.new(sponsor_profile_params.merge(conference_id: @conference.id))
      @sponsor_profile.sub = @current_user[:extra][:raw_info][:sub]

      @sponsor_profile.email = @current_user[:info][:email]
      @sponsor_profile.sponsor_id = @sponsor.id

      respond_to do |format|
        if @sponsor_profile.save
          format.html { redirect_to "/#{@conference.abbr}/sponsor_dashboards/#{@sponsor.id}", notice: 'Speaker was successfully created.' }
        else
          format.html { render :new }
        end
      end
    end
  end

  # PATCH/PUT :event/sponsor_dashboard/speakers/1
  # PATCH/PUT :event/sponsor_dashboard/speakers/1.json
  def update
    authorize @sponsor_profile

    respond_to do |format|
      if @sponsor_profile.update(sponsor_profile_params)
        format.html { redirect_to sponsor_dashboard_path, notice: 'Speaker was successfully updated.' }
        format.json { render :show, status: :ok, location: @speaker }
      else
        format.html { render :edit }
        format.json { render json: @speaker_form.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  helper_method :sponsor_url

  def sponsor_url
    case action_name
    when 'new'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/sponsor_profiles"
    when 'edit', 'update'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/sponsor_profiles/#{params[:id]}"
    end
  end

  def pundit_user
    if @current_user
      SponsorProfile.find_by(conference: @conference.id, email: @current_user[:info][:email])
    end
  end

  def sponsor_profile_params
    params.require(:sponsor_profile).permit(:name,
                                    :sub,
                                    :email,
                                    :conference_id)
  end
end
