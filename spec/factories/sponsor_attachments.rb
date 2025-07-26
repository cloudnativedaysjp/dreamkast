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

FactoryBot.define do
  factory :sponsor_attachment do
    sponsor { nil }
    type { '' }
    url { 'MyString' }
    text { 'MyText' }
    link { 'MyString' }
    public { false }
  end

  factory :sponsor_attachment_logo, class: SponsorAttachmentLogoImage do
    sponsor_id { 1 }
    type { 'SponsorAttachmentLogoImage' }
    url { 'cndo2021/trademark.png' }
  end
end
