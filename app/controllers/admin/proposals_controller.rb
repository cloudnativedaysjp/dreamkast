class Admin::ProposalsController < ApplicationController
  include Secured
  include Logging
  include LogoutHelper

  before_action :is_admin?, :set_conference

  def index
    @proposals = @conference.proposals
    respond_to do |format|
      format.html
    end
  end

  private

  def is_admin?
    raise Forbidden unless admin?
  end
end
