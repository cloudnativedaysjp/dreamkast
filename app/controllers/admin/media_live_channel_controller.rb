class Admin::MediaLiveChannelController < ApplicationController
  include SecuredAdmin

  def start_channel
    channel = MediaLiveChannel.joins(:streaming).where(streamings: { conference_id: current_conference.id }).find(params[:id])
    channel.start_channel
  end

  def stop_channel
    channel = MediaLiveChannel.joins(:streaming).where(streamings: { conference_id: current_conference.id }).find(params[:id])
    channel.stop_channel
  end
end
