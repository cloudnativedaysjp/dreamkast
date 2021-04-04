class VideoRegistration < ApplicationRecord
  belongs_to :talk
  enum status: { not_submitted: 0, submitted: 1, confirmed: 2 }
end
