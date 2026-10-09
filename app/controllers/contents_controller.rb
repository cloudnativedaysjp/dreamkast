class ContentsController < ApplicationController
  include Secured
  before_action :set_conference, :set_profile, :set_speaker

  def logged_in_using_omniauth?
    current_user
  end

  def discussion
    render_if_template_exists(
      "#{current_conference.abbr}_discussion",
      prefixes: controller_path,
      render_target: :"#{current_conference.abbr}_discussion"
    )
  end

  def hands_on
    render_if_template_exists(
      "#{current_conference.abbr}_hands_on",
      prefixes: controller_path,
      render_target: :"#{current_conference.abbr}_hands_on"
    )
  end

  def o11y
    render(:o11y)
  end

  private

  def render_if_template_exists(template, prefixes: [], render_target: template)
    raise(NotFound) unless lookup_context.template_exists?(template, prefixes, false)

    render(render_target)
  end
end
