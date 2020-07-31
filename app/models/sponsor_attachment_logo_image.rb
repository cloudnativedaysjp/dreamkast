class SponsorAttachmentLogoImage < SponsorAttachment
  include SponsorAttachmentFileUploader::Attachment(:file)

  belongs_to :sponsor
end