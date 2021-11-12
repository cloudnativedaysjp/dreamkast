class Admin::AnnouncementsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @announcements = @conference.announcements
  end

  def new
    @announcement = Announcement.new
  end

  def edit
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
  end

  def create
    @announcement = Announcement.new(announcement_params.merge(conference_id: @conference.id))

    respond_to do |format|
      if @announcement.save
        format.html { redirect_to(admin_announcements_path, notice: "Speaker was successfully updated.") }
        format.json { render(:show, status: :ok, location: @announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])

    respond_to do |format|
      if @announcement.update(announcement_params)
        format.html { redirect_to(admin_announcements_path, notice: "Speaker was successfully updated.") }
        format.json { render(:show, status: :ok, location: @announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to(admin_announcements_path, notice: "Announcement was successfully destroyed.") }
      format.json { head(:no_content) }
    end
  end

  private

  helper_method :announcement_url

  def announcement_url
    case action_name
    when "new"
      "/#{params[:event]}/admin/announcements"
    when "edit"
      "/#{params[:event]}/admin/announcements/#{params[:id]}"
    end
  end

  def announcement_params
    params.require(:announcement).permit(:publish_time, :body, :publish, :conference_id)
  end
end
