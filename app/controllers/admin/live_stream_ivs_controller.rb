class Admin::LiveStreamIvsController < ApplicationController
  include SecuredAdmin
  include MediaLiveHelper

  def index
    @tracks = @conference.tracks
    @ivs = LiveStreamIvs.new
    @ivss = @conference.tracks.map(&:live_stream_ivs).compact

    @media_lives = @conference.tracks.map(&:live_stream_media_live).compact
    get_media_live_channels_from_aws(@media_lives.map(&:channel_id)).each do |channel|
      @media_lives.find { |media_live| media_live.channel_id == channel.id }.channel = channel
    end
    get_media_live_inputs_from_aws(@media_lives.map(&:input_id)).each do |input|
      @media_lives.find { |media_live| media_live.input_id == input.id }.input = input
    end

    @media_package_channels = @conference.tracks.map(&:media_package_channel).compact
    @media_package_channels.each(&:channel)

    @media_package_v2_channels = @conference.tracks.map(&:media_package_v2_channel).compact

    respond_to do |format|
      format.html { render(:index) }
      format.json do
        head(:no_content)
        body = render_to_string('admin/live_stream_ivs/index.json.jbuilder')

        Tempfile.open('ivss') do |file|
          file.write(body)
          send_file(file.path, filename: 'ivs_list.json', length: file.size)
        end
      end
    end
  end

  def create
    @ivs = LiveStreamIvs.new
    @ivs.conference_id = @conference.id
    @ivs.track_id = 20
    @ivs.params = {}
    respond_to do |format|
      if @ivs.save
        format.html { redirect_to(admin_live_stream_ivs_path, notice: 'IVS successfully created.') }
        format.json { render(:index, status: :ok, location: @ivs) }
      else
        format.html { render(:index) }
        format.json { render(json: @ivs.errors, status: :unprocessable_entity) }
      end
    end
  end

  def bulk_create
    messages = []
    @conference.tracks.each do |track|
      unless track.live_stream_ivs.present?
        @ivs = LiveStreamIvs.new
        @ivs.conference_id = @conference.id
        @ivs.track_id = track.id
        track.video_platform = 'ivs'

        unless @ivs.save && track.save
          messages << talk.errors
        end
      end
    end

    respond_to do |format|
      if messages.size == 0
        format.html { redirect_to(admin_live_stream_ivs_path, notice: 'IVS successfully created.') }
      else
        format.html { render(:index) }
      end
    end
  end

  def bulk_delete
    params[:ivs].each_key do |id, _|
      ivs = LiveStreamIvs.find(id)
      ivs.destroy
    end

    respond_to do |format|
      format.html { redirect_to(admin_live_stream_ivs_path, notice: '') }
    end
  end
end
