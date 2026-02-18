class Admin::AnnouncementsController < ApplicationController
  include SecuredAdmin

  def index
    @announcements = @conference.announcements
  end

  def new
    @profiles = [@conference.profiles.find(params[:profile_id])] unless params[:profile_id].nil?
    @announcement = Announcement.new
    @announcement.announcement_middles.build
  end

  def edit
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
    @profiles = @announcement.profiles
  end

  def create
    params = announcement_params.merge(conference_id: @conference.id)
    params[:profile_ids] = profile_ids

    @announcement = Announcement.create(params)
    respond_to do |format|
      if @announcement
        format.html { redirect_to(admin_announcements_path, notice: 'Speaker was successfully updated.') }
        format.json { render(:show, status: :ok, location: @announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
    params = announcement_params.merge(conference_id: @conference.id)
    params[:profile_ids] = profile_ids

    respond_to do |format|
      if @announcement.update(params)
        format.html { redirect_to(admin_announcements_path, notice: 'Speaker was successfully updated.') }
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
      format.html { redirect_to(admin_announcements_path, notice: 'Announcement was successfully destroyed.') }
      format.json { head(:no_content) }
    end
  end

  private

  helper_method :announcement_url, :is_to_all_announcements?

  def announcement_url
    case action_name
    when 'new'
      "/#{params[:event]}/admin/announcements"
    when 'edit'
      "/#{params[:event]}/admin/announcements/#{params[:id]}"
    end
  end

  def profile_ids
    params = announcement_params
    return params[:profile_ids] if params[:receiver] == 'person'

    []
  end

  def is_to_all_announcements?
    @profiles.blank? || @profiles.nil? || @profiles.length > 1
  end

  def announcement_params
    params.require(:announcement).permit(:publish_time, :body, :publish, :conference_id, :receiver, profile_ids: [])
  end
end
