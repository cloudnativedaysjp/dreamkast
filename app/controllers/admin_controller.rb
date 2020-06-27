class AdminController < ApplicationController
    include Secured
    include Logging
    include LogoutHelper

    def show
        #TODO: pagenation入れる
    end

    def accesslog
        @logs = AccessLog.all.order(id: "DESC").limit(50)
    end

    def destroy_user
        @profile = Profile.find_by(sub: @current_user[:extra][:raw_info][:sub])
        @profile.destroy
        reset_session
        redirect_to logout_url.to_s
    end
end
