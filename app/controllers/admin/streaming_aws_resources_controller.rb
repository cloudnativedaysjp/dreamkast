class Admin::StreamingAwsResourcesController < ApplicationController
  include SecuredAdmin


  def index
    @tracks = @conference.tracks
  end

  def create
    @streaming_aws_resource = StreamingAwsResource.new(streaming_aws_resource_params.merge(conference_id: @conference.id))

    respond_to do |format|
      if @streaming_aws_resource.save && create_aws_resources
        format.html { redirect_to(admin_streaming_aws_resources_path, notice: 'Streaming AWS Resources is creating...') }
        format.json { render(:show, status: :ok, location: @job) }
      else
        format.html { redirect_to(admin_streaming_aws_resources_path, flash: { error: @job.errors.messages }) }
        format.json { render(json: @job.errors, status: :unprocessable_entity) }
      end
    end
  end

  def create_aws_resources
    @streaming_aws_resource ||= StreamingAwsResource.find(params[:id])
    CreateStreamingAwsResourcesJob.perform_later(@streaming_aws_resource)
  end

  def delete_aws_resources
    @streaming_aws_resource ||= StreamingAwsResource.find(params[:id])
    DeleteStreamingAwsResourcesJob.perform_later(@streaming_aws_resource)
    @streaming_aws_resource.update!(status: 'deleting')
    respond_to do |format|
      format.html { redirect_to(admin_streaming_aws_resources_path, notice: 'Streaming AWS Resources is deleting...') }
      format.json { head(:no_content) }
    end
  end

  def streaming_aws_resource_params
    params.require(:streaming_aws_resource).permit(:id, :conference_id, :track_id, :status)
  end
end
