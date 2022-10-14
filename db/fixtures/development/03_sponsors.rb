
importer = SponsorDataImporter.new
importer.import

uploader = SponsorAttachmentFileUploader.new(:store)

logo_image = File.new(Rails.root.join('app/assets/images/trademark.png'))
uploaded_logo_image = uploader.upload(logo_image)

pdf = File.new(Rails.root.join('app/assets/seeds/dummy.pdf'))
uploaded_pdf = uploader.upload(pdf)

key_image_1 = File.new(Rails.root.join('app/assets/seeds/dummy_sponsor_key_image_1.jpg'))
uploaded_key_image_1 = uploader.upload(key_image_1)

key_image_2 = File.new(Rails.root.join('app/assets/seeds/dummy_sponsor_key_image_2.jpg'))
uploaded_key_image_2 = uploader.upload(key_image_2)

SponsorAttachment.seed(
  { id: 7,
    sponsor_id: 1,
    type: 'SponsorAttachmentText',
    text: DUMMY_TEXT
  },
  { id: 8,
    sponsor_id: 1,
    type: 'SponsorAttachmentPdf',
    title: 'ダミープレゼンテーション',
    file_data: uploaded_pdf.to_json
  },
  { id: 9,
    sponsor_id: 1,
    type: 'SponsorAttachmentVimeo',
    url: 'https://player.vimeo.com/video/442956490'
  },
  { id: 10,
    sponsor_id: 1,
    type: 'SponsorAttachmentKeyImage',
    file_data: uploaded_key_image_1.to_json
  },
  { id: 11,
    sponsor_id: 1,
    type: 'SponsorAttachmentKeyImage',
    file_data: uploaded_key_image_2.to_json
  }
)
