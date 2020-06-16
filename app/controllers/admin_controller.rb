class AdminController < ApplicationController
    def show
        @logs = AccessLog.all
    end
end
