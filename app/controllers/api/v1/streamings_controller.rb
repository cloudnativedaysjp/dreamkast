class Api::V1::StreamingsController < ApplicationController
  # include SecuredPublicApi

  def index
    @conference ||= Conference.find_by(abbr: params[:eventAbbr])
    @tracks = @conference.tracks.includes(streaming: [
                                            :media_live_channel,
                                            :media_live_input,
                                            :media_package_v2_origin_endpoint
                                          ])
    threads = @tracks.map(&:streaming).map { |streaming| [:media_live_channel, :media_live_input, :media_package_v2_origin_endpoint].map { |r| streaming&.send(r) } }.flatten.map do |resource|
      Thread.new do
        resource&.aws_resource
      end
    end
    threads.each(&:join)
    @streamings = @tracks.map(&:streaming)
  end
end
