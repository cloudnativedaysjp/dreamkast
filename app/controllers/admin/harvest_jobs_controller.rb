class Admin::HarvestJobsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @harvest_jobs = @conference.media_package_harvest_jobs
  end

  def new
    @harvest_job = MediaPackageHarvestJob.new
    @talk = Talk.find(params[:talk_id])
    streaming = @talk.track.streaming
    @media_package_channel = streaming.media_package_channel

    @initial_start_time = "#{initial_date}T#{@talk.start_time.strftime('%H:%M')}:00+09:00"
    @initial_end_time = "#{initial_date}T#{@talk.end_time.strftime('%H:%M')}:00+09:00"
    @base_url = streaming.media_package_origin_endpoint.url
    @preview_url = "#{@base_url}?start=#{@initial_start_time}&end=#{@initial_end_time}"
  end

  def create
    @job = MediaPackageHarvestJob.new(harvest_job_params.merge(conference_id: @conference.id))

    respond_to do |format|
      if @job.save
        @job.create_media_package_resources
        format.html { redirect_to(admin_tracks_path, notice: 'HarvestJob was successfully updated.') }
        format.json { render(:show, status: :ok, location: @job) }
      else
        format.html { redirect_to(admin_tracks_path, flash: { error: @job.errors.messages }) }
        format.json { render(json: @job.errors, status: :unprocessable_entity) }
      end
    end
  end

  def initial_date
    @talk.conference_day.date.strftime('%Y-%m-%d')
  end

  def harvest_job_params
    params.require(:media_package_harvest_job).permit(:conference_id, :media_package_channel_id, :talk_id, :start_time, :end_time)
  end
end
