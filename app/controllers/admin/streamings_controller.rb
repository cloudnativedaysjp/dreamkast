class Admin::StreamingsController < ApplicationController
  include SecuredAdmin


  def index
    @tab = params[:tab] || 'default'
    @tracks = @conference.tracks.includes(streaming: [
                                            :conference,
                                            :media_live_channel,
                                            :media_live_input,
                                            :media_package_channel,
                                            :media_package_origin_endpoint,
                                            :media_package_v2_channel_group,
                                            :media_package_v2_origin_endpoint
                                          ])
    threads = @tracks.map(&:streaming).map { |streaming| [:media_live_channel, :media_live_input, :media_package_origin_endpoint, :media_package_v2_origin_endpoint].map { |r| streaming&.send(r) } }.flatten.map do |resource|
      Thread.new do
        resource&.aws_resource
      end
    end
    threads.each(&:join)
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
      format.html { redirect_to(admin_streamings_path, notice: 'Deleting AWS streaming resources...') }
      format.json { head(:no_content) }
    end
  end

  def streaming_params
    params.require(:streaming).permit(:id, :conference_id, :track_id, :status)
  end
end
