class Speaker < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  has_many :talks_speakers
  has_many :talks, through: :talks_speakers

  def self.import(file)
    puts file.class
    destroy_all
    CSV.foreach(file.path, headers: true) do |row|
      speaker = new
      speaker.attributes = row.to_hash.slice(*updatable_attributes)
      speaker.save
    end
  end

  def self.export
    all = CSV.generate do |csv|
      csv << updatable_attributes
      Speaker.all.each do |speaker|
          csv << speaker.attributes.values_at(*updatable_attributes)
      end
    end
    return all
  end

  def self.updatable_attributes
    ["id","name","profile","company","job_title","twitter_id","github_id", "avatar_data"]
  end

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
