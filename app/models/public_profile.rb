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
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :profile

  def twitter_link
    link_to(ActionController::Base.helpers.image_tag('Twitter_Social_Icon_Circle_Color.png', width: 20), "https://twitter.com/#{twitter_id}") if twitter_id.present?
  end

  def github_link
    link_to(ActionController::Base.helpers.image_tag('GitHub-Mark-64px.png', width: 20), "https://github.com/#{github_id}") if github_id.present?
  end
end
