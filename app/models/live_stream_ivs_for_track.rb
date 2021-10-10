class LiveStreamIvsForTrack < LiveStreamIvs
  belongs_to :talk, optional: true
  belongs_to :track

  private

  def channel_name
    "#{env_name_for_tag}_#{conference.abbr}_track#{track.name}"
  end
end
