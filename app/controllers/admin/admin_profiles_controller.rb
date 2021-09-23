class Admin::AdminProfilesController < ApplicationController
  include SecuredAdmin

  def edit
  end

  def update
    respond_to do |format|
      if @admin_profile.update(admin_profile_params)
        format.html { redirect_to edit_admin_admin_profile_path(id: @admin_profile.id)}
      else
        format.html { render :edit }
      end
    end
  end

  private

  def admin_profile_params
    params.require(:admin_profile).permit(
      :name,
      :twitter_id,
      :github_id,
      :avatar
    )
  end
end
