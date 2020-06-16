module Logging
    extend ActiveSupport::Concern

    included do
        before_action :write_accesslog
    end

    def write_accesslog
        AccessLog.create(name: @current_user[:info][:name],
                         sub: @current_user[:extra][:raw_info][:sub],
                         page: controller_name + "/" + action_name + "/" + params[:id].to_s)
    end
end