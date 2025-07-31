class StampRallyConfigure < ApplicationRecord
  include UlidPk
  belongs_to :conference
end
