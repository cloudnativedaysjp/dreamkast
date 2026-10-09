class Profiles::TalksController < ApplicationController
  include Secured
  before_action :set_profile

  def create
    RegisteredTalk.transaction do
      RegisteredTalk.where(profile_id: @profile.id).destroy_all

      params[:talks]&.each_key do |key|
        talk_id = key.to_i
        if talk = Talk.find(talk_id)
          RegisteredTalk.create!(
            profile_id: @profile.id,
            talk_id: talk.id
          )
        end
      end
    end
    redirect_to(dashboard_path)
  rescue => e
    redirect_to(timetables_path, notice: 'セッション登録に失敗しました')
  end
end
