class AdminProfile < ApplicationRecord
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference
end