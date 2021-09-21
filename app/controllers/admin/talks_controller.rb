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
