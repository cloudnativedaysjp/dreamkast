class Admin::TalksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @talks = @conference.talks.accepted.order('conference_day_id ASC, start_time ASC, track_id ASC')
    respond_to do |format|
      format.html
      format.csv do
        head :no_content

        filename = Talk.export_csv(@conference, @talks)
        stat = File::stat("./#{filename}.csv")
        send_file("./#{filename}.csv", filename: "#{filename}.csv", length: stat.size)
      end
    end
  end

  def update_talks
  TalksHelper.update_talks(@conference, params[:video])

    redirect_to admin_talks_url, notice: "配信設定を更新しました"
  end

  def start_on_air
    talk = Talk.find( params[:talk][:id])
    ActiveRecord::Base.transaction do
      talk.conference_day
      talk.track
      other_talk_in_track = @conference.tracks.find_by(name: talk.track.name).talks
                                       .select{|t| t.conference_day.id == talk.conference_day.id && t.id != talk.id}
      other_talk_in_track.each do |talk|
        video = talk.video
        video.on_air = false
        video.save!
      end

      talk.conference_day
      video = talk.video
      video.on_air = true
      video.save!
    end

    ActionCable.server.broadcast(
      "track_channel", Video.on_air(conference)
    )
    ActionCable.server.broadcast(
      "on_air_#{conference.abbr}", Video.on_air_v2
    )

    flash[:notice] = "OnAirに切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}"
    redirect_to admin_tracks_path
  end

  def stop_on_air
    talk = Talk.find(params[:talk][:id])
    video = talk.video
    video.on_air = false
    video.save!

    ActionCable.server.broadcast(
      "track_channel", Video.on_air(conference)
    )
    ActionCable.server.broadcast(
      "on_air_#{conference.abbr}", Video.on_air_v2
    )

    flash[:notice] = "Waiting に切り替えました: #{talk.start_to_end} #{talk.speaker_names.join(',')} #{talk.title}"
    redirect_to admin_tracks_path
  end

  def start_recording
    talk = Talk.find( params[:talk][:id])
    talk.track.live_stream_media_live.set_recording_target_talk(talk.id)
    StartRecordingJob.perform_later(talk)
    redirect_to admin_tracks_path
  end

  def stop_recording
    talk = Talk.find(params[:talk][:id])
    StopRecordingJob.perform_later(talk)
    redirect_to admin_tracks_path
  end

  def bulk_insert_talks
    unless params[:file]
      redirect_to '/admin/talks', notice: "アップロードするファイルを選択してください"
    else
      message = Talk.import(params[:file])
      notice = message.join(" / ")
      redirect_to '/admin/talks', notice: notice
    end
  end

  def bulk_insert_talks_speaker
    unless params[:file]
      redirect_to '/admin/talks', notice: "アップロードするファイルを選択してください"
    else
      TalksSpeaker.import(params[:file])
      redirect_to '/admin/talks', notice: 'CSVの読み込みが完了しました'
    end
  end
end
