FactoryBot.define do
  factory :sponsor_attachment do
    sponsor { nil }
    type { "" }
    url { "MyString" }
    text { "MyText" }
    link { "MyString" }
    public { false }
  end

  factory :sponsor_attachment_logo, class: SponsorAttachmentLogoImage do
    sponsor_id { 1 }
    type { "SponsorAttachmentLogoImage" }
    url { "cndo2021/trademark.png" }
  end
end
