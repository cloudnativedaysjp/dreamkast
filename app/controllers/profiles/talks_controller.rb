class Profiles::TalksController < ApplicationController
  include Secured
  before_action :set_profile

  def new
    @talks = Talk.all
    # register
  end

  def edit
  end

  def create
    RegisteredTalk.transaction do
      RegisteredTalk.where(profile_id: @profile.id).delete_all

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
          params[:talks].each do |key, _value|
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

  def calendar
    respond_to do |format|
      format.ics do
        code = params[:code]
        filename = Profile.find_by(calendar_unique_code: code).export_ics
        stat = File.stat(filename)
        send_file(filename, filename: "#{code}.ics", length: stat.size)
      end
    end
  end

  def update
  end

  def destroy
    @talk.destroy
    respond_to do |format|
      format.html { redirect_to(talks_url, notice: 'Talk was successfully destroyed.') }
      format.json { head(:no_content) }
    end
  end

  private

  def talk_params
    params.require(:talk).permit(:title, :abstract, :movie_url, :track, :start_time, :end_time, :talk_difficulty_id, :talk_category_id)
  end
end
