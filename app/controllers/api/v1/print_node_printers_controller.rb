class Api::V1::PrintNodePrintersController < ApplicationController
  include SecuredAdminApi
  before_action :set_conference, :set_profile

  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def index
    auth = PrintNode::Auth.new(ENV['PRINTNODE_API_KEY'])
    client = PrintNode::Client.new(auth)
    @printers = client.printers
  end
end
