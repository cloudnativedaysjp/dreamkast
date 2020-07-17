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

    end

    def bulk_insert_speakers
        Speaker.import(params[:file])
        redirect_to '/admin/speakers', notice: 'CSVの読み込みが完了しました'
    end

    def bulk_insert_talks_speaker
        TalksSpeaker.import(params[:file])
        redirect_to '/admin/talks', notice: 'CSVの読み込みが完了しました'
    end
    
    private

    def is_admin?
        raise Forbidden unless admin?
    end
end
