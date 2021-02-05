class Admin::SpeakersController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @speakers = @conference.speakers
  end

  def edit
    @speaker = Speaker.find_by_id(params[:id])
  end

  # PATCH/PUT admin/speakers/1
  # PATCH/PUT admih/speakers/1.json
  def update
    @speaker = Speaker.find(params[:id])

    respond_to do |format|
      if @speaker.update(speaker_params)
        format.html { redirect_to admin_speaker_path, notice: "Speaker #{@speaker.name} (id: #{@speaker.id})was successfully updated." }
        format.json { render :show, status: :ok, location: @speaker }
      else
        format.html { render :edit }
        format.json { render json: @speaker.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_insert_speakers
    unless params[:file]
      redirect_to admin_speakers_path, notice: "アップロードするファイルを選択してください"
    else
      message = Speaker.import(params[:file])
      if message.size == 0
        notice = 'CSVの読み込みが完了しました'
      else
        notice = message.join(" / ")
      end
      redirect_to '/admin/speakers', notice: notice
    end
  end

  def export_speakers
    all = Speaker.export
    filename = "./tmp/speaker.csv"
    File.open(filename, 'w') do |file|
      file.write(all)
    end
    # ダウンロード
    stat = File::stat(filename)
    send_file(filename, :filename => "speaker-#{Time.now.strftime("%F")}.csv", :length => stat.size)
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end

  def speaker_params
    params.require(:speaker).permit(:name, :profile, :company, :job_title, :twitter_id, :github_id, :avatar)
  end
end

