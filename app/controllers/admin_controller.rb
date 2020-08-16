class AdminController < ApplicationController
    include Secured
    include Logging
    include LogoutHelper

    before_action :is_admin?

    def show
        @session = session
    end

    def accesslog
        #TODO: pagenation入れる
        @logs = AccessLog.all.order(id: "DESC").limit(50)
    end

    def destroy_user
        @profile = Profile.find_by(sub: @current_user[:extra][:raw_info][:sub])
        @profile.destroy
        reset_session
        redirect_to logout_url.to_s
    end

    def users
        @profiles = Profile.all
    end

    def talks
        @talks = Talk.all.order('conference_day_id ASC, start_time ASC, track_id ASC')
    end

    def update_talks
        params[:video].each do |talk_id, value|
            talk = Talk.find(talk_id)
            if talk.video
                video = Talk.find(talk_id).video
            else
                video = Video.new
                video.talk_id = talk.id
            end
            video.video_id = value[:video_id]
            video.slido_id = value[:slido_id]
            if value[:on_air]
                video.on_air = true 
            else
                video.on_air = false 
            end
            video.save
        end
        ActionCable.server.broadcast(
            "track_channel", Video.on_air
        )

        redirect_to '/admin/talks', notice: "配信設定を更新しました"
    end

    def statistics
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

    def speakers
        @speakers = Speaker.all
    end

    def edit_speaker
        @speaker = Speaker.find_by_id(params[:id])
    end

    # PATCH/PUT admin/speakers/1
    # PATCH/PUT admih/speakers/1.json
    def update_speaker
        @speaker = Speaker.find(params[:id])

        respond_to do |format|
            if @speaker.update(speaker_params)
                format.html { redirect_to "/admin/speakers", notice: "Speaker #{@speaker.name} (id: #{@speaker.id})was successfully updated." }
                format.json { render :show, status: :ok, location: @speaker }
            else
                format.html { render :edit }
                format.json { render json: @speaker.errors, status: :unprocessable_entity }
            end
        end
    end

    def bulk_insert_speakers
        unless params[:file]
            redirect_to '/admin/speakers', notice: "アップロードするファイルを選択してください"
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

    def bulk_insert_talks_speaker
        unless params[:file]
            redirect_to '/admin/talks', notice: "アップロードするファイルを選択してください"
        else
            TalksSpeaker.import(params[:file])
            redirect_to '/admin/talks', notice: 'CSVの読み込みが完了しました'
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

    def export_statistics
        f = Tempfile.create("statistics.csv")
        @conference = Conference.includes(talks: [:registered_talks]).find_by(abbr: Conference.first.abbr)
        CSV.open(f.path, "wb") do |csv|
            csv << %w[id item count]
            csv << ["", "registered_user_count", Profile.count]
            @conference.talks.each do |talk|
                csv << %W[#{talk.id} #{talk.title} #{talk.registered_talks.size}]
            end
        end
        send_file(f.path, filename: "statistics-#{Time.now.strftime("%F")}.csv", length: File::stat(f.path).size)
    end

    private

    def is_admin?
        raise Forbidden unless admin?
    end

    def speaker_params
        params.require(:speaker).permit(:name, :profile, :company, :job_title, :twitter_id, :github_id, :avatar)
    end
end
