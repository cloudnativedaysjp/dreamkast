class ProfilesController < ApplicationController
  include Secured

  before_action :set_conference
  before_action :set_current_profile, only: [:edit, :update, :destroy]
  skip_before_action :logged_in_using_omniauth?, only: [:new]
  before_action :is_admin?, :find_profile, only: [:destroy_id, :set_role]
  OCCUPATIONS = %w[インフラエンジニア ソフトウェア開発エンジニア サポートエンジニア 学生 その他]

  def new
    @occupations = OCCUPATIONS
    @profile = Profile.new
    @conference = Conference.find_by(abbr: params[:event])
    if set_current_user && Profile.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
      redirect_to dashboard_path
    end

    @event = params[:event]
  end

  def edit
    @occupations = OCCUPATIONS
  end

  def create
    @profile = Profile.new(profile_params.merge(conference_id: @conference.id))
    @profile.sub = @current_user[:extra][:raw_info][:sub]
    @profile.email = @current_user[:info][:email]

    if @profile.save
      Agreement.create!(profile_id: @profile.id, form_item_id: 1, value: 1) if agreement_params["require_email"]
      Agreement.create!(profile_id: @profile.id, form_item_id: 2, value: 1) if agreement_params["require_tel"]
      Agreement.create!(profile_id: @profile.id, form_item_id: 3, value: 1) if agreement_params["require_posting"]
      Agreement.create!(profile_id: @profile.id, form_item_id: 4, value: 1) if agreement_params["agree_ms"]
      Agreement.create!(profile_id: @profile.id, form_item_id: 5, value: 1) if agreement_params["agree_ms_cndo2021"]
      redirect_to "/#{event_name}/timetables"
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end
    
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to edit_profile_path(id: @profile.id)}
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile.destroy
    reset_session
    redirect_to logout_url.to_s
  end

  def destroy_id
    @found_profile.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def set_role
    puts params[:roles]
  end

  def profile_url
    case action_name
    when 'new'
      "/#{params[:event]}/profiles"
    when 'edit'
      "/#{params[:event]}/profiles/#{params[:id]}"
    end
  end

  helper_method :profile_url

  private
    def find_profile
      @found_profile = Profile.find(parmas[:id])
      unless @found_profile
        format.json { render json: "Not found", status: :not_found }
      end
    end

    def set_current_profile
      @profile = Profile.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)
    end

    def profile_params
      params.require(:profile).permit(
        :sub,
        :email,
        :last_name,
        :first_name,
        :last_name_kana,
        :first_name_kana,
        :industry_id,
        :occupation,
        :company_name,
        :company_email,
        :company_address,
        :company_tel,
        :department,
        :position,
        :roles,
        :conference_id
        )
    end

    def agreement_params
      params.require(:profile).permit(
        :require_email,
        :require_tel,
        :require_posting,
        :agree_ms,
        :agree_ms_cndo2021
      )
    end
end
