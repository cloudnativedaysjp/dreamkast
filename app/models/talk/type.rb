class Talk < ApplicationRecord
  class Type < ApplicationRecord
    # NOTE: KeynoteSession and Intermission have been migrated to session attributes system
    # Only Session and SponsorSession remain as they are still actively used
    KLASSES = [Session, KeynoteSession, SponsorSession, Intermission].freeze
  end
end
