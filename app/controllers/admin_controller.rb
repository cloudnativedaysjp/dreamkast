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
        @talks = Talk.all
    end

    def bulk_insert_talks
        Talk.import(params[:file])
        redirect_to '/admin/talks', notice: 'CSVの読み込みが完了しました'
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
                format.html { redirect_to @speaker, notice: 'Speaker was successfully updated.' }
                format.json { render :show, status: :ok, location: @speaker }
            else
                format.html { render :edit }
                format.json { render json: @speaker.errors, status: :unprocessable_entity }
            end
        end
    end

    def bulk_insert_speakers
        Speaker.import(params[:file])
        redirect_to '/admin/speakers', notice: 'CSVの読み込みが完了しました'
    end

    def bulk_insert_talks_speaker
        TalksSpeaker.import(params[:file])
        redirect_to '/admin/talks', notice: 'CSVの読み込みが完了しました'
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
