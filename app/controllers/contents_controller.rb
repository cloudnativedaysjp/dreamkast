class ContentsController < ApplicationController
  include Secured
  before_action :set_profile, :set_speaker

  def logged_in_using_omniauth?
    current_user
  end

  def index
  end

  def discussion
    @conference = Conference.find_by(abbr: params[:event])
    render_if_template_exists(
      "#{@conference.abbr}_discussion",
      prefixes: controller_path,
      render_target: "#{@conference.abbr}_discussion".to_sym
    )
  end

  def kontest
    @conference = Conference.find_by(abbr: params[:event])
  end

  def hands_on
    @conference = Conference.find_by(abbr: params[:event])
    render_if_template_exists(
      "#{@conference.abbr}_hands_on",
      prefixes: controller_path,
      render_target: "#{@conference.abbr}_hands_on".to_sym
    )
  end

  def job_board
    @conference = Conference.find_by(abbr: params[:event])
    render_if_template_exists(
      "#{@conference.abbr}_job_board",
      prefixes: controller_path,
      render_target: "#{@conference.abbr}_job_board".to_sym
    )
  end

  def o11y
    @conference = Conference.find_by(abbr: params[:event])
    render(:o11y)
  end

  def community_lt
    @conference = Conference.find_by(abbr: params[:event])
    render_if_template_exists("contents/#{@conference.abbr}/community_lt")
  end

  def yurucafe
    @conference = Conference.find_by(abbr: params[:event])
    render_if_template_exists("contents/#{@conference.abbr}/yurucafe")
  end

  def stamprally
    @conference = Conference.find_by(abbr: params[:event])
    render_if_template_exists("contents/#{@conference.abbr}/stamprally")
  end

  private

  def render_if_template_exists(template, prefixes: [], render_target: template)
    raise(NotFound) unless lookup_context.template_exists?(template, prefixes, false)

    render(render_target)
  end
end
