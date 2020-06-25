class Talk < ApplicationRecord
  belongs_to :talk_category
  belongs_to :talk_difficulty
end
