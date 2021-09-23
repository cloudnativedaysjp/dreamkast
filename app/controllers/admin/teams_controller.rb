class Admin::TeamsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def show
    @admin_profiles = @conference.admin_profiles.where(show_on_team_page: true).order(name: 'ASC')
  end

  def update
    ActiveRecord::Base.transaction do
      params['team'].each do |k, v|
        admin_profile = AdminProfile.find(k)
        if admin_profile.present?
          admin_profile.show_on_team_page = v
          admin_profile.save!
        end
      end
    end

    redirect_to admin_team_path
  rescue => e
    redirect_to admin_team_path, notice: "更新に失敗しました: #{e}"
  end
end
