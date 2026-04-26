require 'rails_helper'

RSpec.describe(SponsorSpeakerInviteAccept, type: :model) do
  describe 'Speaker : Sponsor の 1:1 制約' do
    let!(:conference) { create(:cndt2020, :registered) }
    let!(:sponsor_a) { create(:sponsor, id: 1, conference:, abbr: 'sponsor_a') }
    let!(:sponsor_b) { create(:sponsor, id: 2, conference:, abbr: 'sponsor_b') }
    let!(:sponsor_a_contact) { create(:sponsor_contact, conference:, sponsor: sponsor_a) }
    let!(:sponsor_b_contact) { create(:sponsor_contact, conference:, sponsor: sponsor_b) }
    let!(:speaker) { create(:speaker, conference:, name: 'n', profile: 'p', company: 'c', job_title: 'j') }
    let!(:invite_a) { create(:sponsor_speaker_invite, conference:, sponsor: sponsor_a) }
    let!(:invite_b) { create(:sponsor_speaker_invite, conference:, sponsor: sponsor_b) }
    let!(:first_accept) do
      create(:sponsor_speaker_invite_accept,
             conference:, sponsor: sponsor_a, sponsor_contact: sponsor_a_contact,
             speaker:, sponsor_speaker_invite: invite_a)
    end

    it '同じ (conference, speaker) で別 sponsor の 2つ目の InviteAccept は作成できない' do
      duplicate = SponsorSpeakerInviteAccept.new(
        conference:, sponsor: sponsor_b, sponsor_contact: sponsor_b_contact,
        speaker:, sponsor_speaker_invite: invite_b
      )

      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:speaker_id]).to(include(match(/別スポンサー/)))
    end

    it '別 conference の場合は作成できる' do
      another_conference = create(:cndo2021, :registered)
      another_sponsor = create(:sponsor, id: 99, conference: another_conference, abbr: 'other')
      another_contact = create(:sponsor_contact, conference: another_conference, sponsor: another_sponsor)
      another_speaker = create(:speaker, conference: another_conference, name: 'n', profile: 'p', company: 'c', job_title: 'j', user_id: speaker.user_id)
      another_invite = create(:sponsor_speaker_invite, conference: another_conference, sponsor: another_sponsor)

      another_accept = SponsorSpeakerInviteAccept.new(
        conference: another_conference, sponsor: another_sponsor, sponsor_contact: another_contact,
        speaker: another_speaker, sponsor_speaker_invite: another_invite
      )

      expect(another_accept).to(be_valid)
    end
  end
end
