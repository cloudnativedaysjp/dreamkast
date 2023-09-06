class Api::V1::StreamingsController < ApplicationController
  include SecuredPublicApi

  def index
    @conference ||= Conference.find_by(abbr: params[:eventAbbr])
    @streamings = @conference.streamings
  end
end
