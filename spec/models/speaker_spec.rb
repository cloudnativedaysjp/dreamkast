# == Schema Information
#
# Table name: speakers
#
#  id                   :bigint           not null, primary key
#  additional_documents :text(65535)
#  avatar_data          :text(65535)
#  company              :string(255)
#  email                :text(65535)
#  job_title            :string(255)
#  name                 :string(255)
#  name_mother_tongue   :string(255)
#  profile              :text(65535)
#  sub                  :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  conference_id        :integer
#  github_id            :string(255)
#  twitter_id           :string(255)
#
require 'rails_helper'

RSpec.describe(Speaker, type: :model) do
  before { create(:cndt2020) }

  describe '#proposal_accepted?' do
    subject { speaker.proposal_accepted? }

    context 'when speaker has accepted talk' do
      let!(:speaker) { create(:speaker_alice, :with_talk1_accepted) }
      it { expect(subject).to(be_truthy) }
    end

    context 'when speaker has accepted and rejected talks' do
      let!(:speaker) { create(:speaker_alice, :with_talk1_accepted) }
      before { speaker.talks << create(:talk_rejekt) }
      it { expect(subject).to(be_truthy) }
    end

    context 'when speaker has only rejected talk' do
      let!(:speaker) { create(:speaker_alice, :with_talk1_rejected) }
      it { expect(subject).to(be_falsey) }
    end
  end
end
