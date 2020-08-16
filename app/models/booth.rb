class Booth < ApplicationRecord
  belongs_to :conference
  belongs_to :sponsor
end