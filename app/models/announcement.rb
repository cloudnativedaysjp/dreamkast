class Announcement < ApplicationRecord
  belongs_to :conference

  scope :published, -> {
    where(publish: true)
  }
end