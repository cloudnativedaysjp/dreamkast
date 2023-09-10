class Admin::StreamingsController < ApplicationController
  include SecuredAdmin


  def index
    @tracks = @conference.tracks
  end

  def create
    @streaming = Streaming.new(streaming_params.merge(conference_id: @conference.id))

    respond_to do |format|
      if @streaming.save && create_aws_resources
        format.html { redirect_to(admin_streamings_path, notice: 'Creating AWS streaming resources. Please wait few minutes') }
        format.json { render(:show, status: :ok, location: @job) }
      else
        format.html { redirect_to(admin_streaming_path, flash: { error: @job.errors.messages }) }
        format.json { render(json: @job.errors, status: :unprocessable_entity) }
      end
    end
  end

  def create_aws_resources
    @streaming ||= Streaming.find(params[:id])
    CreateStreamingAwsResourcesJob.perform_later(@streaming)
  end

  def delete_aws_resources
    @streaming ||= Streaming.find(params[:id])
    DeleteStreamingAwsResourcesJob.perform_later(@streaming)
    @streaming.update!(status: 'deleting')
    respond_to do |format|
      format.html { redirect_to(admin_streamings_path, notice: 'Streaming AWS Resources is deleting...') }
      format.json { head(:no_content) }
    end
  end

  def streaming_params
    params.require(:streaming).permit(:id, :conference_id, :track_id, :status)
  end
end
