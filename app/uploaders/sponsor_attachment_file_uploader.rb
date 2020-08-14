class SponsorAttachmentFileUploader < Shrine
  def generate_location(io, metadata: {}, **options)
    "sponsor_attachment/#{super}"
  end
end
