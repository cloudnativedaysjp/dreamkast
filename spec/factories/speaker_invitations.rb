# == Schema Information
#
# Table name: speaker_invitations
#
#  id            :integer          not null, primary key
#  talk_id       :integer          not null
#  conference_id :integer          not null
#  email         :string(255)      not null
#  token         :string(255)      not null
#  expires_at    :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_speaker_invitations_on_conference_id  (conference_id)
#  index_speaker_invitations_on_talk_id        (talk_id)
#

FactoryBot.define do
  factory :speaker_invitation do
    email { 'MyString' }
    token { 'MyString' }
    talk { nil }
    conference { nil }
    expires_at { '2024-09-05 20:27:25' }
  end
end
