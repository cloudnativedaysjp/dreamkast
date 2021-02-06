class Admin::TimetablesController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @talks = @conference.talks.order('conference_day_id ASC, start_time ASC, track_id ASC')
    @tracks = Track.where(conference_id: @conference.id)
    respond_to do |format|
      format.html
    end
  end

  def update
    @talks = []
    talks_params.each do |id, talk_param|
      talk = Talk.find(id)
      talk.update(talk_param)
      @talks << talk
    end
    redirect_to admin_timetables_path,  notice: "タイムテーブルを更新しました"
  end

  private

  def talks_params
    params.permit(talks: [:track_id, :date, :start_time, :end_time])[:talks]
  end
end
