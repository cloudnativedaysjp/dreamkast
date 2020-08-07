class SponsorAttachmentPdf < SponsorAttachment
  include SponsorAttachmentFileUploader::Attachment(:file)

  MAX_POSTS_COUNT = 3

  validate :posts_count_must_be_within_limit

  private

  def posts_count_must_be_within_limit
    errors.add(:base, "posts count limit: #{MAX_POSTS_COUNT}") if sponsor.sponsor_attachment_pdfs.count >= MAX_POSTS_COUNT
  end
end