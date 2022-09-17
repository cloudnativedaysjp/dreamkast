class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def set_uuid
    while self.id.blank? || self.class.find_by(id: self.id).present? do
      self.id = SecureRandom.uuid
    end
  end
end
