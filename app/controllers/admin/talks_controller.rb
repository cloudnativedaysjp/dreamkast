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

    talk.conference_day
    talk.track
    if @conference.tracks.find_by(name: talk.track.name).talks
                  .select{|t| t.conference_day.id == talk.conference_day.id && t.id != talk.id}
                  .map(&:video)
                  .map(&:on_air)
                  .any?
      flash[:danger] = "他にOnAir中のセッションがあります。"
      redirect_to admin_tracks_path
    else



    talk.conference_day
    video = talk.video
    video.on_air = true
    video.save!

    ActionCable.server.broadcast(
      "track_channel", Video.on_air(conference)
    )
    ActionCable.server.broadcast(
      "on_air_#{conference.abbr}", Video.on_air_v2
    )

    flash[:notice] = "配信設定を更新しました"
    redirect_to admin_tracks_path
    end
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

    redirect_to admin_tracks_path, notice: "配信設定を更新しました"
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
