# == Schema Information
#
# Table name: sponsor_attachments
#
#  id         :bigint           not null, primary key
#  file_data  :string(255)
#  link       :string(255)
#  public     :boolean
#  text       :text(65535)
#  title      :string(255)
#  type       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sponsor_id :bigint           not null
#
# Indexes
#
#  index_sponsor_attachments_on_sponsor_id  (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (sponsor_id => sponsors.id)
#

class SponsorAttachmentPdf < SponsorAttachment
  include SponsorAttachmentFileUploader::Attachment(:file)

  MAX_POSTS_COUNT = 3

  validate :posts_count_must_be_within_limit

  private

  def posts_count_must_be_within_limit
    errors.add(:base, "posts count limit: #{MAX_POSTS_COUNT}") if sponsor.sponsor_attachment_pdfs.count > MAX_POSTS_COUNT
  end
end
