class Talk < ApplicationRecord
  class Type < ApplicationRecord
    KLASSES = [Session, KeynoteSession, SponsorSession, Intermission].freeze
  end
end
