# == Schema Information
#
# Table name: talk_types
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Talk < ApplicationRecord
  class Type < ApplicationRecord
    KLASSES = [Session, KeynoteSession, SponsorSession, Intermission].freeze
  end
end
