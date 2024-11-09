class Admin::HarvestJobsController < ApplicationController
  include SecuredAdmin

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
    @talk = Talk.find(harvest_job_params[:talk_id])
    @job = MediaPackageHarvestJob.new(harvest_job_params.merge(conference_id: @conference.id))

    if @job.save && @job.create_media_package_resources
      flash.now.notice = "#{@talk.title} のアーカイブ作成用HarvestJobの作成に成功しました"
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def initial_date
    @talk.conference_day.date.strftime('%Y-%m-%d')
  end

  def harvest_job_params
    params.require(:media_package_harvest_job).permit(:conference_id, :media_package_channel_id, :talk_id, :start_time, :end_time)
  end

  helper_method :turbo_stream_flash

  private

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
