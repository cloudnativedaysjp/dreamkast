class AdminProfile < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference

  def has_avatar?
    ! self.avatar_url.nil?
  end

  def avatar_or_dummy_url
    if has_avatar?
      return avatar_url
    else
      return 'dummy.png'
    end
  end

  def twitter_link
    link_to ActionController::Base.helpers.image_tag("Twitter_Social_Icon_Circle_Color.png", width: 20), "https://twitter.com/#{twitter_id}" if twitter_id.present?
  end

  def github_link
    link_to ActionController::Base.helpers.image_tag("GitHub-Mark-64px.png", width: 20), "https://github.com/#{github_id}" if github_id.present?
  end
end