class ContentsController < ApplicationController
  include Secured
  before_action :set_conference, :set_profile, :set_speaker

  def logged_in_using_omniauth?
    current_user
  end

  def o11y
    render(:o11y)
  end
end
