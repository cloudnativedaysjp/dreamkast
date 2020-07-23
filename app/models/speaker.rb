class Speaker < ApplicationRecord
  include AvatarUploader::Attachment(:avatar)

  has_many :talks_speakers
  has_many :talks, through: :talks_speakers

  validates :name, presence: true
  validates :profile, presence: true
  validates :company, presence: true
  validates :job_title, presence: true

  def self.import(file)
    message = []
    destroy_all
    CSV.foreach(file.path, headers: true) do |row|
      speaker = new
      speaker.attributes = row.to_hash.slice(*updatable_attributes)
      unless speaker.save
        message << "id: #{speaker.id} のレコードでエラーが発生しています"
      end
    end
    return message
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
end
