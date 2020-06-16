class AdminController < ApplicationController
    include Secured
    include Logging

    def show
        #TODO: pagenation入れる
        @logs = AccessLog.all.order(id: "DESC").limit(50)
    end
end
