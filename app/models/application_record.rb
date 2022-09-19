class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def set_uuid
    self.id = SecureRandom.uuid while id.blank? || self.class.find_by(id:).present?
  end
end
