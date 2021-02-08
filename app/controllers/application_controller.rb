class Forbidden < ActionController::ActionControllerError; end

class ApplicationController < ActionController::Base
  include Pundit

  before_action :set_raven_context, :event_exists?

  unless Rails.env.development?
    rescue_from Exception, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from Forbidden, with: :render_403
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    render template: 'errors/error_403', status: 403, layout: 'application', content_type: 'text/html'
  end

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

  def talk_category(talk)
    @talk_cagetogies.find(talk.talk_category_id)
  end

  def talk_difficulty(talk)
    @talk_difficulties.find(talk.talk_difficulty_id)
  end

  helper_method :home_controller?, :admin_controller?, :event_name, :talks_checked?, :talk_category, :talk_difficulty

  def render_403
    render template: 'errors/error_403', status: 403, layout: 'application', content_type: 'text/html'
  end

  def render_404
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def render_500(e = nil)
    if e
      logger.error "Rendering 500 with exception: #{e.message}"
      logger.error e.backtrace.join("\n")
    end

    render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
  end

  helper_method :sponsor_logo_class, :days
  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def event_exists?
    if event_name && Conference.where(abbr: event_name).empty?
      raise ActiveRecord::RecordNotFound
    end
  end

  def days
    day_of_the_week = %w(月 火 水 木 金 土 日)
    d = @conference.conference_days.where(internal: false)
    if d.length == 1
      day = day_of_the_week[d.first.date.cwday - 1]
      return d.first.date.strftime("%Y年%m月%d日") + "(#{day})"
    else
      first = d.order(:date).first
      fday = day_of_the_week[first.date.cwday - 1]
      last = d.order(:date).last
      lday = day_of_the_week[last.date.cwday - 1]
      return "#{first.date.strftime("%Y年%m月%d日")}(#{fday})〜#{last.date.strftime("%Y年%m月%d日")}(#{lday})"
    end
  end

  def set_conference
    @conference = Conference.find_by(abbr: event_name)
  end

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end

  def set_speaker
    if @current_user
      @speaker = Speaker.find_by(email: @current_user[:info][:email])
    end
  end

  def event_view
    if FileTest.exist?("#{Rails.root}/app/views/#{controller_name}/#{event_name}_#{action_name}.html.erb")
      "#{controller_name}/#{event_name}_#{action_name}.html.erb"
    else
      "#{controller_name}/#{action_name}.html.erb"
    end
  end
end
