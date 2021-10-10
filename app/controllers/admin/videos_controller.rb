class Admin::VideosController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @talks = @conference.talks
  end

  def edit
    @video = Video.find(params[:id])
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    ivs = Aws::IVS::Client.new(region: 'us-east-1', credentials: creds)
    s3 = Aws::S3::Client.new(region: 'us-east-1', credentials: creds)
    sts = Aws::STS::Client.new(region: 'us-east-1', credentials: creds)

    account_id = sts.get_caller_identity.account

    live_stream_id = @video.talk.live_stream_ivs.channel_arn.split('/')[1]
    bucket_name = ivs.get_recording_configuration(arn: @video.talk.live_stream_ivs.recording_configuration_arn).recording_configuration.destination_configuration.s3.bucket_name

    resp = s3.list_objects_v2(bucket: bucket_name, prefix: "ivs/v1/#{account_id}/#{live_stream_id}/")
    @medias = []
    # [
    #   "ivs/v1/607167088920/vnVxjfxL2QCt/2021/10/10/4/40/SNnN2FWybYJX//media/hls/160p30/playlist.m3u8",
    #   "ivs/v1/607167088920/vnVxjfxL2QCt/2021/10/10/4/40/SNnN2FWybYJX//media/hls/1080p/playlist.m3u8",
    #   "ivs/v1/607167088920/vnVxjfxL2QCt/2021/10/10/4/40/SNnN2FWybYJX//media/hls/720p30/playlist.m3u8",
    #   "ivs/v1/607167088920/vnVxjfxL2QCt/2021/10/10/4/40/SNnN2FWybYJX//media/hls/480p30/playlist.m3u8",
    #   "ivs/v1/607167088920/vnVxjfxL2QCt/2021/10/10/4/40/SNnN2FWybYJX//media/hls/360p30/playlist.m3u8"
    # ].each do |path|
    #   @medias << [path, path]
    # end

    resp.contents.each do |content|
      if content.key.end_with?('recording-ended.json')
        o = s3.get_object(bucket: bucket_name, key: content.key)
        info = JSON.parse(o.body.read)
        path = info['media']['hls']['path']
        info['media']['hls']['renditions'].each do |redition|
          @medias << [
            "#{content.key.sub(/\/events\/recording-ended.json/, '')}/#{path}/#{redition['path']}/#{redition['playlist']}",
            "#{content.key.sub(/\/events\/recording-ended.json/, '')}/#{path}/#{redition['path']}/#{redition['playlist']}"
          ]
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to admin_talks_path}
      else
        format.html { render :edit }
      end
    end
  end

  def video_params
    params.require(:video).permit(
      :video_id,
    )
  end
end
