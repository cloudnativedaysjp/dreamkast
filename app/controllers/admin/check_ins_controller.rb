class Admin::CheckInsController < ApplicationController
  include SecuredAdmin

  def index
    @profiles = Profile.where(conference_id: @conference.id, participation: '現地参加')
  end

  def create
    @check_in = CheckIn.new(check_in_params)
    @profile = Profile.find(@check_in.profile_id)
    if @check_in.save
      redirect_to(admin_profiles_path, notice: "#{@profile.last_name} #{@profile.first_name} がチェックインしました")
    else
      redirect_to(admin_profiles_path, notice: "#{@profile.last_name} #{@profile.first_name} のチェックインに失敗しました")
    end
  end

  def destroy
    @check_in = CheckIn.find_by_id(params[:id])
    @profile = Profile.find(@check_in.profile_id)
    if @check_in.destroy
      redirect_to(admin_profiles_path, notice: "#{@profile.last_name} #{@profile.first_name} のチェックインを解除しました")
    else
      redirect_to(admin_profiles_path, notice: "#{@profile.last_name} #{@profile.first_name} のチェックイン解除に失敗しました")
    end
  end

  def check_in_params
    params.require(:check_in).permit(:id, :profile_id)
  end
end
