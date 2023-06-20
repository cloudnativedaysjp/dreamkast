# == Schema Information
#
# Table name: public_profiles
#
#  id          :bigint           not null, primary key
#  avatar_data :text(65535)
#  is_public   :boolean          default(FALSE)
#  nickname    :string(255)      default("")
#  github_id   :string(255)      default("")
#  profile_id  :bigint           not null
#  twitter_id  :string(255)      default("")
#
# Indexes
#
#  index_public_profiles_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
class PublicProfile < ApplicationRecord
  include AvatarUploader::Attachment(:avatar)

  belongs_to :profile
end
