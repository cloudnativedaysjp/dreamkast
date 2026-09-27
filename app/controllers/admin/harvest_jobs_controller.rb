class Admin::HarvestJobsController < ApplicationController
  include SecuredAdmin

  def index
    # 状態の更新は util:polling_harvest_job_and_update_video が行う（完了時に Video も更新するため、ここでは更新しない）
    @harvest_jobs = @conference.media_package_v2_harvest_jobs.order(start_time: :desc)
  end

  def new
    @harvest_job = MediaPackageV2HarvestJob.new
    @talk = Talk.find(params[:talk_id])
    @archive_origin_endpoint = @talk.track.streaming&.media_package_v2_archive_origin_endpoint

    @initial_start_time = "#{initial_date}T#{@talk.start_time.strftime('%H:%M')}:00+09:00"
    @initial_end_time = "#{initial_date}T#{@talk.end_time.strftime('%H:%M')}:00+09:00"
    @base_url = @archive_origin_endpoint&.hls_manifest_url
    @preview_url = "#{@base_url}?start=#{@initial_start_time}&end=#{@initial_end_time}" if @base_url
  end

  def create
    @talk = Talk.find(harvest_job_params[:talk_id])
    @job = MediaPackageV2HarvestJob.new(harvest_job_params.merge(conference_id: @conference.id))

    if @job.save && @job.create_aws_resource
      flash.now.notice = "#{@talk.title} のアーカイブ作成用HarvestJobの作成に成功しました"
    else
      flash.now.alert = "HarvestJobの作成に失敗しました: #{@job.errors.full_messages.join(', ')}"
      render(:create, status: :unprocessable_entity)
    end
  rescue Aws::MediaPackageV2::Errors::ServiceError => e
    @job.update(status: MediaPackageV2HarvestJob::STATUS_FAILED, error_message: e.message) if @job&.persisted?
    flash.now.alert = "HarvestJobの作成に失敗しました: #{e.message}"
    render(:create, status: :unprocessable_entity)
  end

  def initial_date
    @talk.conference_day.date.strftime('%Y-%m-%d')
  end

  def harvest_job_params
    params.require(:media_package_v2_harvest_job).permit(:media_package_v2_archive_origin_endpoint_id, :talk_id, :start_time, :end_time)
  end

  helper_method :turbo_stream_flash

  private

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
