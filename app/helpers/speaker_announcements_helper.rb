module SpeakerAnnouncementsHelper
  def is_to_all_announcements?(speakers)
    speakers.blank? || speakers.nil? || speakers.length > 1
  end
end
