class Talk < ApplicationRecord
  has_one :talk_category
  has_one :talk_difficulty
end
