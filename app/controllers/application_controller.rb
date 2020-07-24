class Forbidden < ActionController::ActionControllerError; end

class ApplicationController < ActionController::Base
  before_action :set_raven_context

  rescue_from Exception, with: :render_500
  rescue_from Forbidden, with: :render_403

  def home_controller?
    controller_name == "home"
  end

  def admin_controller?
    controller_name == "admin"
  end

  def event_name
    params[:event]
  end

  # ActiveRecordの機能でもうちょっといい感じにかける気はする…
  def talks_checked?(talk_id)
    @profile.talks.select{|talk| talk.id == talk_id}.present?
  end

  def talk_category(talk_id)
    @talk_cagetogies.find{|category| category.id == @conference.talks.find{|talk| talk.id == talk_id}.talk_category_id}
  end

  def talk_difficulty(talk_id)
    @talk_difficulties.find{|difficulty| difficulty.id == @conference.talks.find{|talk| talk.id == talk_id}.talk_difficulty_id}
  end

  helper_method :home_controller?, :admin_controller?, :event_name, :talks_checked?, :talk_category, :talk_difficulty

  def render_403(e)
    @exception = e
    render template: 'errors/error_403', status: 403, layout: 'application', content_type: 'text/html'
  end

  def render_404
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def redirect_to_root
    redirect_to "/#{params[:event]}"
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
  # rescue_from ActiveRecord::RecordNotFound, with: :render_404

end
