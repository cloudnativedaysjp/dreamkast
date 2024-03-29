class Api::V1::Talks::VideoRegistrationController < ApplicationController
  include SecuredPublicApi

  before_action :set_talk
  skip_before_action :verify_authenticity_token

  def show
    if @talk.video_registration.present?
      @video_registration = @talk.video_registration
      render(:show, formats: :json, type: :jbuilder)
    else
      render(json: { message: 'Not Found' }, status: 404)
    end
  end

  def update
    if @talk.video_registration
      video_registration = @talk.video_registration
    else
      video_registration = VideoRegistration.new(talk_id: @talk.id)
      video_registration.statistics = '{}'
    end
    @params ||= JSON.parse(request.body.read, { symbolize_names: true })
    if @params[:url] && (@params[:statistics] || @params[:status])
      render(json: { message: 'You cannot update url and other params at the same time.' }, status: 400)
      return
    end
    if @params[:url]
      video_registration.url = @params[:url]
    else
      video_registration.status = @params[:status]
      video_registration.statistics = @params[:statistics].to_json if @params[:statistics]
    end
    video_registration.save
    render(json: { message: 'OK' }, status: 200)
  end

  private

  def set_talk
    begin
      @talk = Talk.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render(json: { message: 'Not Found' }, status: 404)
    end
  end
end
