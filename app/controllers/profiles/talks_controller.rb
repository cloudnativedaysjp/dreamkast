class Profiles::TalksController < ApplicationController
  include Secured
  before_action :set_profile

  def create
    RegisteredTalk.transaction do
      RegisteredTalk.where(profile_id: @profile.id).destroy_all

      if params[:talks].present?
        if params[:event] == 'cndt2020'
          params[:talks].each do |key, value|
            day_id, slot = key.split('_')
            track_id = value

            Talk.find_by_params(day_id, slot, track_id).each do |talk|
              RegisteredTalk.create!(
                profile_id: @profile.id,
                talk_id: talk.id
              )
            end
          end
        else
          params[:talks].each_key do |key|
            talk_id = key.to_i
            if talk = Talk.find(talk_id)
              RegisteredTalk.create!(
                profile_id: @profile.id,
                talk_id: talk.id
              )
            end
          end
        end
      end
    end
    redirect_to(dashboard_path)
  rescue => e
    redirect_to(timetables_path, notice: 'セッション登録に失敗しました')
  end
end
