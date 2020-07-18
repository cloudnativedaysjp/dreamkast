class Speaker < ApplicationRecord
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

  def self.updatable_attributes
    ["id","name","profile","company","job_title","twitter_id","github_id"]
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
end
