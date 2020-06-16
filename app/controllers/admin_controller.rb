class AdminController < ApplicationController
    include Secured

    def show
        @logs = AccessLog.all
    end
end
