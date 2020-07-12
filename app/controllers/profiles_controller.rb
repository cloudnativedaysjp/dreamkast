class ProfilesController < ApplicationController
  include Secured

  before_action :set_current_profile, only: [:edit, :update, :destroy]
  before_action :is_admin?, :find_profile, only: [:destroy_id, :set_role]

  def new
    @profile = Profile.new
  end

  def edit
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.sub = @current_user[:extra][:raw_info][:sub]
    @profile.email = @current_user[:info][:email]

    if @profile.save
      Agreement.create!(profile_id: @profile.id, form_item_id: 1, value: 1) if agreement_params["require_email"]
      Agreement.create!(profile_id: @profile.id, form_item_id: 2, value: 1) if agreement_params["require_tel"]
      Agreement.create!(profile_id: @profile.id, form_item_id: 3, value: 1) if agreement_params["require_posting"]
      redirect_to '/track/1'
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
        format.html { redirect_to '/profiles/edit', notice: '登録情報を更新しました' }
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

  private
    def find_profile
      @found_profile = Profile.find(parmas[:id])
      unless @found_profile
        format.json { render json: "Not found", status: :not_found }
      end
    end

    def set_current_profile
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end

    def profile_params
      params.require(:profile).permit(
        :sub,
        :email,
        :last_name,
        :first_name,
        :industry_id,
        :occupation,
        :company_name,
        :company_email,
        :company_address,
        :company_tel,
        :department,
        :position,
        :roles,
        )
    end

    def agreement_params
      params.require(:profile).permit(
        :require_email,
        :require_tel,
        :require_posting
      )
    end
end
