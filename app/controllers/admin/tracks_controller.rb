class Admin::TracksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper
  include TalksTable

  def index
    @date = params[:date] || @conference.conference_days.first.date.strftime('%Y-%m-%d')
    @conference_day = @conference.conference_days.select { |day| day.date.strftime('%Y-%m-%d') == @date }.first
    @track_name = params[:track_name] || @conference.tracks.first.name
    @track = @conference.tracks.find_by(name: @track_name)
    @track.live_stream_media_live.get_channel_from_aws if @track.live_stream_media_live
    @talks = @conference
             .talks
             .where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id)
             .order('conference_day_id ASC, start_time ASC, track_id ASC')

    respond_to do |format|
      format.html
      format.js { render(:index) }
      format.csv do
        head(:no_content)
        filename = Talk.export_csv(@conference, @talks, @track_name, @date)
        stat = File.stat("./#{filename}.csv")
        send_file("./#{filename}.csv", filename: "#{filename}.csv", length: stat.size)
      end
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
end
