class Admin::AttendeeAnnouncementsController < ApplicationController
  include SecuredAdmin

  def index
    @attendee_announcements = @conference.attendee_announcements
  end

  def new
    @profiles = [@conference.profiles.find(params[:profile_id])] unless params[:profile_id].nil?
    @attendee_announcement = AttendeeAnnouncement.new
    @attendee_announcement.attendee_announcement_middles.build
  end

  def edit
    @attendee_announcement = AttendeeAnnouncement.find_by(conference_id: @conference.id, id: params[:id])
    @profiles = @attendee_announcement.profiles
  end

  def create
    params = attendee_announcement_params.merge(conference_id: @conference.id)
    params[:profile_ids] = profile_ids

    @attendee_announcement = AttendeeAnnouncement.create(params)
    respond_to do |format|
      if @attendee_announcement
        format.html { redirect_to(admin_attendee_announcements_path, notice: 'Announcement was successfully updated.') }
        format.json { render(:show, status: :ok, location: @attendee_announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @attendee_announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    @attendee_announcement = AttendeeAnnouncement.find_by(conference_id: @conference.id, id: params[:id])
    params = attendee_announcement_params.merge(conference_id: @conference.id)
    params[:profile_ids] = profile_ids

    respond_to do |format|
      if @attendee_announcement.update(params)
        format.html { redirect_to(admin_attendee_announcements_path, notice: 'Announcement was successfully updated.') }
        format.json { render(:show, status: :ok, location: @attendee_announcement) }
      else
        format.html { render(:edit) }
        format.json { render(json: @attendee_announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @attendee_announcement = AttendeeAnnouncement.find_by(conference_id: @conference.id, id: params[:id])
    @attendee_announcement.destroy

    respond_to do |format|
      format.html { redirect_to(admin_attendee_announcements_path, notice: 'Announcement was successfully destroyed.') }
      format.json { head(:no_content) }
    end
  end

  private

  helper_method :attendee_announcement_url, :is_to_all_announcements?

  def profile_ids
    params = attendee_announcement_params

    case params[:receiver]
    when 'person'
      params[:profile_ids]
    when 'all_attendee'
      @conference.profiles.pluck(:id)
    when 'only_online'
      @conference.profiles.online.pluck(:id)
    when 'only_offline'
      @conference.profiles.offline.pluck(:id)
    when 'early_bird'
      @conference.profiles.where('created_at < ?', @conference.early_bird_cutoff_at).pluck(:id)
    end
  end

  def is_to_all_announcements?
    @profiles.blank? || @profiles.nil? || @profiles.length > 1
  end

  def attendee_announcement_url
    case action_name
    when 'new'
      "/#{params[:event]}/admin/attendee_announcements"
    when 'edit'
      "/#{params[:event]}/admin/attendee_announcements/#{params[:id]}"
    end
  end

  def attendee_announcement_params
    params.require(:attendee_announcement).permit(:conference_id, :receiver, :publish_time, :body, :publish,
                                                  profile_ids: [])
  end
end
