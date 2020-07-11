class FormItem < ApplicationRecord
  belongs_to :conference
  has_many :agreements
  has_many :profiles, through: :agreements
end
