module Logging
    extend ActiveSupport::Concern

    included do
        before_action :write_accesslog
    end

    def write_accesslog
        @user = session[:userinfo]
        AccessLog.create(name: @user[:info][:name],
                         sub: @user[:extra][:raw_info][:sub],
                         page: controller_name + "/" + action_name)
    end
end