class Admin::TalksController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @talks = @conference.talks.order('conference_day_id ASC, start_time ASC, track_id ASC')
    respond_to do |format|
      format.html
      format.csv do
        head :no_content

        filename = "#{@conference.abbr}_talks"
        columns = %w[title abstract speaker talk_time]

        csv = CSV.generate do |csv|
          #カラム名を1行目として入れる
          csv << columns

          @talks.each do |talk|
            csv << [talk.title, talk.abstract, talk.speakers.map(&:name).join(", "), talk.time]
          end
        end

        File.open("./#{filename}.csv", "w", encoding: "SJIS") do |file|
          file.write(csv)
        end
        stat = File::stat("./#{filename}.csv")
        send_file("./#{filename}.csv", filename: "#{filename}.csv", length: stat.size)
      end
    end
  end

  def update_talks
  TalksHelper.update_talks(params[:video])

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

  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
