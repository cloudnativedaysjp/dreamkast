# == Schema Information
#
# Table name: admin_profiles
#
#  id                :bigint           not null, primary key
#  avatar_data       :text(65535)
#  email             :string(255)
#  name              :string(255)
#  show_on_team_page :boolean
#  sub               :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  conference_id     :bigint           not null
#  github_id         :string(255)
#  twitter_id        :string(255)
#
# Indexes
#
#  index_admin_profiles_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class AdminProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference

  def has_avatar?
    !avatar_url.nil?
  end

  def avatar_or_dummy_url(size = :small)
    if has_avatar?
      avatar_url(size) || avatar_url
    else
      'dummy.png'
    end
  end

  def twitter_link
    link_to(ActionController::Base.helpers.image_tag('Twitter_Social_Icon_Circle_Color.png', width: 20), "https://twitter.com/#{twitter_id}") if twitter_id.present?
  end

  def github_link
    link_to(ActionController::Base.helpers.image_tag('GitHub-Mark-64px.png', width: 20), "https://github.com/#{github_id}") if github_id.present?
  end
end
