# == Schema Information
#
# Table name: speakers
#
#  id                   :bigint           not null, primary key
#  additional_documents :text(65535)
#  avatar_data          :text(65535)
#  company              :string(255)
#  email                :text(65535)
#  job_title            :string(255)
#  name                 :string(255)
#  name_mother_tongue   :string(255)
#  profile              :text(65535)
#  sub                  :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  conference_id        :integer
#  github_id            :string(255)
#  twitter_id           :string(255)
#
class Speaker < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include AvatarUploader::Attachment(:avatar)

  belongs_to :conference

  has_many :talks_speakers
  has_many :talks, through: :talks_speakers

  validates :name, presence: true
  validates :profile, presence: true
  validates :company, presence: true
  validates :job_title, presence: true
  validates :conference_id, presence: true

  def proposals
    talks.map(&:proposals)
  end

  def sponsor_talks
    talks.filter { |talk| talk.sponsor.present? }
  end

  def self.import(file)
    message = []

    speakers = []

    CSV.foreach(file.path, headers: true) do |row|
      speaker = new
      hash = row.to_hash.slice(*updatable_attributes)
      hash[:created_at] = Time.now
      hash[:updated_at] = Time.now
      speaker.attributes = hash
      if speaker.valid?
        speakers << hash
      else
        message << "id: #{speaker.id} - #{speaker.errors.messages}"
      end
    end

    if message.size == 0
      upsert_all(speakers)
    end

    message
  end

  def self.export
    CSV.generate do |csv|
      csv << updatable_attributes
      Speaker.all.each do |speaker|
        csv << speaker.attributes.values_at(*updatable_attributes)
      end
    end
  end

  def self.updatable_attributes
    %w[id conference_id name profile company job_title twitter_id github_id avatar_data]
  end

  def has_avatar?
    !avatar_url.nil?
  end

  def avatar_or_dummy_url
    if has_avatar?
      avatar_url
    else
      "dummy.png"
    end
  end

  def twitter_link
    link_to(ActionController::Base.helpers.image_tag("Twitter_Social_Icon_Circle_Color.png", width: 20), "https://twitter.com/#{twitter_id}") if twitter_id.present?
  end

  def github_link
    link_to(ActionController::Base.helpers.image_tag("GitHub-Mark-64px.png", width: 20), "https://github.com/#{github_id}") if github_id.present?
  end
end
