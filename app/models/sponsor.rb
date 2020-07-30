class Sponsor < ApplicationRecord
  belongs_to :conference
  has_many :sponsor_attachment_texts
end
