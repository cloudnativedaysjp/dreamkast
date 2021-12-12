class Admin::SpeakerAnnouncementsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @speaker_announcements = @conference.speaker_announcements
  end

  def new
    @speakers = [Speaker.find(params[:speaker_id])] unless params[:speaker_id].nil?
    @speaker_announcement = SpeakerAnnouncement.new
    @speaker_announcement.speaker_announcement_middles.build
  end

  def edit
    @speaker_announcement = SpeakerAnnouncement.find_by(conference_id: @conference.id, id: params[:id])
    @speakers = @speaker_announcement.speakers
  end

  def create
    @speaker_announcement = SpeakerAnnouncement.create(speaker_announcement_params.merge(conference_id: @conference.id))

    respond_to do |format|
      if @speaker_announcement
        format.html { redirect_to(admin_speaker_announcements_path, notice: "Speaker was successfully updated.") }
        format.json { render(:show, status: :ok, location: @speaker_announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @speaker_announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    @speaker_announcement = SpeakerAnnouncement.find_by(conference_id: @conference.id, id: params[:id])

    respond_to do |format|
      if @speaker_announcement.update(speaker_announcement_params)
        format.html { redirect_to(admin_speaker_announcements_path, notice: "Speaker was successfully updated.") }
        format.json { render(:show, status: :ok, location: @speaker_announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @speaker_announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @speaker_announcement = SpeakerAnnouncement.find_by(conference_id: @conference.id, id: params[:id])
    @speaker_announcement.destroy

    respond_to do |format|
      format.html { redirect_to(admin_speaker_announcements_path, notice: "Announcement was successfully destroyed.") }
      format.json { head(:no_content) }
    end
  end

  private

  helper_method :speaker_announcement_url

  def speaker_announcement_url
    case action_name
    when "new"
      "/#{params[:event]}/admin/speaker_announcements"
    when "edit"
      "/#{params[:event]}/admin/speaker_announcements/#{params[:id]}"
    end
  end

  def speaker_announcement_params
    params.require(:speaker_announcement).permit(:conference_id, :publish_time, :body, :publish, :speaker_names, speaker_announcement_middles_attributes: [:id, :speaker_id, :_destroy])
  end
end
