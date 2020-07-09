class ApplicationController < ActionController::Base
  before_action :set_raven_context

  def event_page?
    controller_name == "event"
  end

  helper_method :event_page?
  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  # rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def render_404
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end
end
