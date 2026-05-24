class Admin::AnnouncementsController < ApplicationController
  include SecuredAdmin

  def index
    @announcements = @conference.announcements
  end

  def new
    @announcement = Announcement.new
  end

  def edit
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
  end

  def deliveries
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
    @announcement_deliveries = @announcement.announcement_deliveries.includes(:profile).order(id: :desc)
  end

  def create
    params = announcement_params.merge(conference_id: @conference.id)
    Rails.logger.info(
      "[Admin::AnnouncementsController#create] conference=#{@conference.id} " \
      "publish=#{params[:publish].inspect} receiver=#{params[:receiver].inspect} " \
      "publish_time=#{params[:publish_time].inspect}"
    )

    @announcement = Announcement.create(params)
    Rails.logger.info(
      "[Admin::AnnouncementsController#create] announcement=#{@announcement.id.inspect} " \
      "persisted=#{@announcement.persisted?} errors=#{@announcement.errors.full_messages.join(', ')}"
    )
    respond_to do |format|
      if @announcement.persisted?
        format.html { redirect_to(admin_announcements_path, notice: 'Announcement was successfully created.') }
        format.json { render(:show, status: :created, location: @announcement) }
      else
        format.html { render(:new) }
        format.json { render(json: @announcement.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    @announcement = Announcement.find_by(conference_id: @conference.id, id: params[:id])
    params = announcement_params.merge(conference_id: @conference.id)
    Rails.logger.info(
      "[Admin::AnnouncementsController#update] announcement=#{@announcement&.id.inspect} " \
      "conference=#{@conference.id} publish=#{params[:publish].inspect} " \
      "receiver=#{params[:receiver].inspect} publish_time=#{params[:publish_time].inspect}"
    )

    respond_to do |format|
      if @announcement.update(params)
        Rails.logger.info(
          "[Admin::AnnouncementsController#update] updated announcement=#{@announcement.id} " \
          "publish=#{@announcement.publish.inspect} send_status=#{@announcement.send_status.inspect}"
        )
        format.html { redirect_to(admin_announcements_path, notice: 'Announcement was successfully updated.') }
        format.json { render(:show, status: :ok, location: @announcement) }
      else
        Rails.logger.warn(
          "[Admin::AnnouncementsController#update] failed announcement=#{@announcement.id} " \
          "errors=#{@announcement.errors.full_messages.join(', ')}"
        )
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

  helper_method :announcement_url

  def announcement_url
    case action_name
    when 'new'
      "/#{params[:event]}/admin/announcements"
    when 'edit'
      "/#{params[:event]}/admin/announcements/#{params[:id]}"
    end
  end

  def announcement_params
    params.require(:announcement).permit(:publish_time, :body, :publish, :conference_id, :receiver)
  end
end
