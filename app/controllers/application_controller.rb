class Forbidden < ActionController::ActionControllerError; end

class NotFound < ActionController::ActionControllerError; end

class ApplicationController < ActionController::Base
  include EnvHelper
  include Pundit

  before_action :set_sentry_context, :event_exists?

  unless Rails.env.development?
    rescue_from Exception, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, NotFound, with: :render_404
    rescue_from Forbidden, with: :render_403
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    render(template: 'errors/error_403', status: 403, layout: 'application', content_type: 'text/html')
  end

  def home_controller?
    controller_name == 'home'
  end

  def admin_controller?
    controller_name == 'admin'
  end

  def event_name
    params[:event]
  end

  def production?
    env_name == 'production'
  end

  # ActiveRecordの機能でもうちょっといい感じにかける気はする…
  def talks_checked?(talk_id)
    @profile.talks.select { |talk| talk.id == talk_id }.present?
  end

  def talk_category(talk)
    @talk_categories.find(talk.talk_category_id)
  end

  def talk_difficulty(talk)
    @talk_difficulties.find(talk.talk_difficulty_id)
  end

  helper_method :home_controller?, :admin_controller?, :event_name, :production?, :talks_checked?, :talk_category, :talk_difficulty, :display_speaker_dashboard_link?

  def render_403
    render(template: 'errors/error_403', status: 403, layout: 'application', content_type: 'text/html')
  end

  def render_404
    render(template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html', formats: :html)
  end

  def render_500(e = nil)
    if e
      logger.error("Rendering 500 with exception: #{e.message}")
      logger.error(e.backtrace.join("\n"))
    end

    render(template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html')
  end

  def render_400
    render(json: { message: 'bad request' }, status: 400, formats: :json)
  end

  # カンファレンス開催前、かつCFP中
  # カンファレンス開催前、かつ自身が登壇者の場合(CFP締め切り後)
  # カンファレンス開催中、かつ自身が登壇者の場合
  # カンファレンス開催後、かつ自身が登壇者の場合（開催後に資料URLを追加することを想定）
  def display_speaker_dashboard_link?
    (@conference.registered? && @conference.speaker_entry_enabled?) || (@conference.registered? && @speaker.present?) || (@conference.opened? && @speaker.present?) || (@conference.closed? && @speaker.present?)
  end

  helper_method :sponsor_logo_class, :days

  private

  def set_sentry_context
    Sentry.with_scope do |scope|
      scope.set_user(id: session[:current_user_id])
      scope.set_extras(params: params.to_unsafe_h, url: request.url)
    end
  end

  def event_exists?
    if event_name && Conference.where(abbr: event_name).empty?
      raise(ActiveRecord::RecordNotFound)
    end
  end

  def days
    day_of_the_week = %w(月 火 水 木 金 土 日)
    d = @conference.conference_days.where(internal: false)
    if d.length == 1
      day = day_of_the_week[d.first.date.cwday - 1]
      d.first.date.strftime('%Y年%m月%d日') + "(#{day})"
    else
      first = d.order(:date).first
      fday = day_of_the_week[first.date.cwday - 1]
      last = d.order(:date).last
      lday = day_of_the_week[last.date.cwday - 1]
      "#{first.date.strftime("%Y年%m月%d日")}(#{fday})〜#{last.date.strftime("%Y年%m月%d日")}(#{lday})"
    end
  end

  def set_conference
    @conference ||= Conference.find_by(abbr: event_name)
  end

  def set_profile
    @profile = if @current_user && (set_conference.opened? || set_conference.registered?)
                 Profile.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)
               else
                 GuestProfile.new
               end
  end

  def set_speaker
    if @current_user
      @speaker = Speaker.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)
    end
  end

  def event_view
    if FileTest.exist?("#{Rails.root}/app/views/#{controller_name}/#{event_name}_#{action_name}.html.erb")
      "#{event_name}_#{action_name}"
    else
      action_name.to_s
    end
  end
end
