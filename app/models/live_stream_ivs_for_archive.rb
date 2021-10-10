class LiveStreamIvsForArchive < LiveStreamIvs
  belongs_to :talk
  belongs_to :track, optional: true

  private

  def channel_name
    "#{env_name_for_tag}_#{conference.abbr}_talk#{talk.id}"
  end
end
