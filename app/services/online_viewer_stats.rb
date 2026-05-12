class OnlineViewerStats
  RESCUABLE = [
    ActiveRecord::ConnectionNotEstablished,
    ActiveRecord::NoDatabaseError,
    ActiveRecord::StatementInvalid,
    Mysql2::Error
  ].freeze

  def initialize(conference)
    @conference = conference
  end

  def unique_viewers_count
    safely do
      TrackViewer.for_talk_ids(talk_ids).distinct.count(:profile_id)
    end
  end

  def viewer_counts_by_talk
    safely do
      TrackViewer.for_talk_ids(talk_ids).group(:talk_id).distinct.count(:profile_id)
    end
  end

  private

  def talk_ids
    @talk_ids ||= @conference.talks.pluck(:id)
  end

  def safely
    return nil if talk_ids.empty?

    yield
  rescue *RESCUABLE => e
    Rails.logger.warn("[OnlineViewerStats] unavailable: #{e.class}: #{e.message}")
    nil
  end
end
