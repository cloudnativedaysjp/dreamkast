class Admin::TalksController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @talks = @conference.talks.accepted.order('conference_day_id ASC, start_time ASC, track_id ASC')
    respond_to do |format|
      format.html
      format.csv do
        head :no_content

        filename = "#{@conference.abbr}_talks"
        columns = %w[id title abstract speaker session_time difficulty category created_at twitter_id]
        labels = @conference.proposal_item_configs.map(&:label).uniq
        labels.delete('session_time')
        columns.concat(labels)

        csv = CSV.generate do |csv|
          #カラム名を1行目として入れる
          csv << columns

          @talks.each do |talk|
            row = [talk.id, talk.title, talk.abstract, talk.speaker_names.join(", "), talk.time, talk.talk_difficulty.name, talk.talk_category.name, talk.created_at, talk.speaker_twitter_ids.join(", ")]
            labels.each do |label|
              v = talk.proposal_item_value(label)
              row << (v.class == Array ? v.join(', ') : v)
            end
            csv << row
          end
        end

        File.open("./#{filename}.csv", "w", encoding: "UTF-8") do |file|
          file.write(csv)
        end
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

  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
