class Admin::TalksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper
  include TalksTable

  def index
    @talks = @conference.talks.accepted_and_intermission.order('conference_day_id ASC, start_time ASC, track_id ASC')
    respond_to do |format|
      format.html
      format.csv do
        head(:no_content)

        filename = Talk.export_csv(@conference, @talks)
        stat = File.stat("./#{filename}.csv")
        send_file("./#{filename}.csv", filename: "#{filename}.csv", length: stat.size)
      end
    end
  end

  def update_talks
    TalksHelper.update_talks(@conference, params[:video])

    redirect_to(admin_talks_url, notice: '配信設定を更新しました')
  end

  def start_on_air
    date = params[:talk][:date]
    track_name = params[:talk][:track_name]
    talk = Talk.find(params[:talk][:id])

    respond_to do |format|
      on_air_talks_of_other_days = talk.track.talks.accepted_and_intermission.reject { |t| t.conference_day.id == talk.conference_day.id }.select { |t| t.video.on_air? }
      if on_air_talks_of_other_days.size.positive?
        format.html {
          update_variables_for_tracks(talk)
          redirect_to(admin_tracks_path(date:, track_name:), alert: "Talk id=#{on_air_talks_of_other_days.map(&:id).join(',')} are already on_air.")
        }
        format.turbo_stream {
          update_variables_for_tracks(talk)
          flash[:alert] = "Talk id=#{on_air_talks_of_other_days.map(&:id).join(',')} are already on_air."
        }
      else
        talk.start_streaming
        format.html {
          update_variables_for_tracks(talk)
          redirect_to(admin_tracks_path(date:, track_name:), notice: "OnAirに切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}")
        }
        format.turbo_stream {
          update_variables_for_tracks(talk)
          flash[:notice] = "OnAirに切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}"
        }
      end
    end
  end

  def stop_on_air
    date = params[:talk][:date]
    track_name = params[:talk][:track_name]
    talk = Talk.find(params[:talk][:id])
    talk.stop_streaming
    @conference_day = talk.conference_day
    @track = talk.track
    @talks = talk.track
                 .talks
                 .where(conference_day_id: talk.conference_day.id, track_id: talk.track.id)
                 .order('conference_day_id ASC, start_time ASC, track_id ASC').includes(:video, :speakers, :conference_day, :track)

    respond_to do |format|
      format.html {
        redirect_to(admin_tracks_path(date:, track_name:), notice: "Waiting に切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}")
      }
      format.turbo_stream {
        flash[:notice] = "Waiting に切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}"
      }
    end
  end

  def start_recording
    talk = Talk.find(params[:talk][:id])

    @date = params[:talk][:date] || @conference.conference_days.first.date.strftime('%Y-%m-%d')
    @conference_day = @conference.conference_days.select { |day| day.date.strftime('%Y-%m-%d') == @date }.first
    @track_name = params[:talk][:track_name] || @conference.tracks.first.name
    @track = talk.track
    @track.live_stream_media_live.get_channel_from_aws if @track.live_stream_media_live
    @talks = @conference
             .talks
             .where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id)
             .order('conference_day_id ASC, start_time ASC, track_id ASC')

    media_live = @track.live_stream_media_live
    unless media_live
      flash[:danger] = 'LiveStreamMediaLiveリソースが存在していません。AdminのIVSメニューから作成してください'
      respond_to do |format|
        format.js { render('admin/tracks/index.js') }
      end
    end

    media_live.get_channel_from_aws

    if media_live.channel_state != LiveStreamMediaLive::CHANNEL_IDLE
      flash[:danger] = "Channel Stateが #{media_live.channel_state}です。MediaLiveの録画処理が完全に停止するまで録画は開始できません。"
      respond_to do |format|
        format.js { render('admin/tracks/index.js') }
      end
    else
      @track.live_stream_media_live.set_recording_target_talk(talk.id)
      @track.live_stream_media_live.start_channel
      @track.live_stream_media_live.get_channel_from_aws

      respond_to do |format|
        format.js { render('admin/tracks/index.js') }
      end
    end
  end

  def stop_recording
    talk = Talk.find(params[:talk][:id])

    @date = params[:talk][:date] || @conference.conference_days.first.date.strftime('%Y-%m-%d')
    @conference_day = @conference.conference_days.select { |day| day.date.strftime('%Y-%m-%d') == @date }.first
    @track_name = params[:talk][:track_name] || @conference.tracks.first.name
    @track = talk.track
    @track.live_stream_media_live.get_channel_from_aws if @track.live_stream_media_live
    @talks = @conference
             .talks
             .where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id)
             .order('conference_day_id ASC, start_time ASC, track_id ASC')
    @track.live_stream_media_live.stop_channel
    @track.live_stream_media_live.get_channel_from_aws
    talk.video.update!(site: 's3', video_id: talk.track.live_stream_media_live.playback_url)

    respond_to do |format|
      format.js { render('admin/tracks/index.js') }
    end
  end

  private

  def update_variables_for_tracks(talk)
    @conference_day = talk.conference_day
    @track = talk.track
    @talks = Talk.all.where(conference_day_id: @conference_day.id, track_id: @track.id)
                 .order('conference_day_id ASC, start_time ASC, track_id ASC').includes(:video, :speakers, :conference_day, :track)
  end
end
