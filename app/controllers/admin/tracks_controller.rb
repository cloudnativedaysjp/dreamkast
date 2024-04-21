class Admin::TracksController < ApplicationController
  include SecuredAdmin

  def index
    @date = params[:date] || @conference.conference_days.first.date.strftime('%Y-%m-%d')
    @conference_day = @conference.conference_days.select { |day| day.date.strftime('%Y-%m-%d') == @date }.first
    @track_name = params[:track_name] || @conference.tracks.first.name
    @track = @conference.tracks.find_by(name: @track_name)
    @talks = @conference
             .talks
             .where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id)
             .order('conference_day_id ASC, start_time ASC, track_id ASC').includes(:video, :speakers, :conference_day, :track)

    respond_to do |format|
      format.html
      format.js { render(:index) }
      format.turbo_stream
      format.csv { export_talks(@conference, @talks, @track_name, @date) }
    end
  end

  def update_tracks
    track = Track.find(params[:track][:id])
    track.video_id = params[:track][:video_id]

    respond_to do |format|
      if track.save && TalksHelper.update_talks(@conference, params[:video])
        format.js
      end
    end
  end

  def update_offset
    params[:time][0].each do |id, value|
      Talk.find(id).update!(
        start_offset: value[:startOffset],
        end_offset: value[:endOffset]
      )
    end
    ActionCable.server.broadcast(
      "on_air_#{conference.abbr}", Video.on_air_v2(conference.id)
    )
    redirect_to(admin_tracks_path, flash: { success: 'Offset updated' })
  end

  private

  def export_talks(conference, talks, track_name, date)
    head(:no_content)
    filepath = Talk.export_csv(conference, talks, track_name, date)
    stat = File.stat(filepath)
    send_file(filepath, filename: File.basename(filepath), length: stat.size)
  end
end
