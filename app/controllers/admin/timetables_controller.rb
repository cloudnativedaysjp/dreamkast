class Admin::TimetablesController < ApplicationController
  include SecuredAdmin

  before_action :set_profile

  def index
    @talks = @conference.talks.show_on_timetable.order('conference_day_id ASC, start_time ASC, track_id ASC')
    @tracks = Track.where(conference_id: @conference.id)
    @conference_form = ConferenceForm.new(conference: @conference)
    respond_to(&:html)
  end

  def update
    @talks = []
    talks_params.each do |id, talk_param|
      talk = Talk.find(id)
      end_time = ''
      if talk_param[:start_time] != ''
        end_time = (Time.parse(talk_param[:start_time]) + (talk.time * 60)).to_formatted_s(:db)
      end
      talk.update(talk_param.merge(end_time:))
      @talks << talk
    end
    redirect_to(admin_timetables_path, notice: 'タイムテーブルを更新しました')
  end

  def publish
    @conference = Conference.find_by(abbr: params[:event])

    respond_to do |format|
      if @conference.update(show_timetable: 1)
        format.html { redirect_to(admin_timetables_path(event: params[:event]), notice: 'Timetable has published.') }
      else
        format.html { render(:edit) }
      end
    end
  end

  def close
    @conference = Conference.find_by(abbr: params[:event])

    respond_to do |format|
      if @conference.update(show_timetable: 0)
        format.html { redirect_to(admin_timetables_path(event: params[:event]), notice: 'Timetable has closed.') }
      else
        format.html { render(:edit) }
      end
    end
  end

  def preview
    @talks = @conference.talks.order('conference_day_id ASC, start_time ASC, track_id ASC')
    @tracks = Track.where(conference_id: @conference.id)
    @talk_categories = TalkCategory.where(conference_id: @conference.id)
    @talk_difficulties = TalkDifficulty.where(conference_id: @conference.id)
    respond_to(&:html)
  end

  private

  helper_method :timetable_partial_name
  def talks_params
    params.permit(talks: [:track_id, :conference_day_id, :start_time])[:talks]
  end

  def timetable_partial_name
    if params[:event] == 'cndo2021'
      'timetable_cndo2021'
    else
      'timetable'
    end
  end
end
