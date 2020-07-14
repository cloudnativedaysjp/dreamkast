class TimetableController < ApplicationController
  include Secured
  before_action :set_profile

  def logged_in_using_omniauth?
    if session[:userinfo].present?
      @current_user = session[:userinfo]
    end
  end

  def index
    @conference = Conference.includes(:talks).find_by(abbr: event_name)
    @talks = Talk.eager_load(:talk_category, :talk_difficulty).all
    @talk_cagetogies = TalkCategory.all
    @talk_difficulties = TalkDifficulty.all
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

  helper_method :talks_checked?, :talk_category, :talk_difficulty

  private

  def set_profile
    if @current_user
      @profile = Profile.find_by(email: @current_user[:info][:email])
    end
  end
end
