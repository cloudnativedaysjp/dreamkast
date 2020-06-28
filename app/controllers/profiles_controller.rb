class ProfilesController < ApplicationController
  include Secured

  before_action :set_profile, only: [:edit, :update, :destroy]

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
        format.html { redirect_to '/profiles/edit', notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: 'Profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_profile
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end

    def profile_params
      params.require(:profile).permit(:sub, :email, :last_name, :first_name, :industry_id, :occupation, :company_name, :company_email, :company_address, :company_tel, :department, :position)
    end
end
