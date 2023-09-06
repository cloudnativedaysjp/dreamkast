class Api::V1::StreamingsController < ApplicationController
  # include SecuredAdmin

  def index
    p 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAa'
    p params
    p @conference ||= Conference.find_by(abbr: params[:eventAbbr])
    p @streamings = @conference.streamings
  end
end
