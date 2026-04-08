class FormItem < ApplicationRecord
  belongs_to :conference

  has_many :form_values
  has_many :profiles, through: :form_values, source: :profile

  validates :name, presence: true
  validates :attr, presence: true
end
