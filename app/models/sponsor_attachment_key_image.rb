# == Schema Information
#
# Table name: sponsor_attachments
#
#  id         :integer          not null, primary key
#  sponsor_id :integer          not null
#  type       :string(255)
#  title      :string(255)
#  url        :string(255)
#  text       :text(65535)
#  link       :string(255)
#  public     :boolean
#  file_data  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sponsor_attachments_on_sponsor_id  (sponsor_id)
#

class SponsorAttachmentKeyImage < SponsorAttachment
  include SponsorAttachmentFileUploader::Attachment(:file)

  MAX_POSTS_COUNT = 2

  validate :posts_count_must_be_within_limit

  private

  def posts_count_must_be_within_limit
    errors.add(:base, "posts count limit: #{MAX_POSTS_COUNT}") if sponsor.sponsor_attachment_key_images.count > MAX_POSTS_COUNT
  end
end
