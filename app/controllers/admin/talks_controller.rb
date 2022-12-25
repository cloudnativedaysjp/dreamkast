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
    talk = Talk.find(params[:talk][:id])

    respond_to do |format|
      on_air_talks_of_other_days = talk.track.talks.accepted.reject { |t| t.conference_day.id == talk.conference_day.id }.select { |t| t.video.on_air? }
      if on_air_talks_of_other_days.size.positive?
        flash[:alert] = "Talk id=#{on_air_talks_of_other_days.map(&:id).join(',')} are already on_air."
        format.js { render(json: { error: "Talk id=#{on_air_talks_of_other_days.map(&:id).join(',')} are already on_air." }, status: 200) }
      else
        talk.start_streaming
        flash[:notice] = "OnAirに切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}"
        format.js { render(json: { message: 'OK' }, status: 200) }
      end
    end
  end

  def stop_on_air
    talk = Talk.find(params[:talk][:id])
    talk.stop_streaming

    flash[:notice] = "Waiting に切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}"
    respond_to do |format|
      format.js { render(json: { message: 'OK' }, status: 200) }
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
end
