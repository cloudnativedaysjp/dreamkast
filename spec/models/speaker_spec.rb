# == Schema Information
#
# Table name: speakers
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  profile              :text(65535)
#  company              :string(255)
#  job_title            :string(255)
#  twitter_id           :string(255)
#  github_id            :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  avatar_data          :text(65535)
#  conference_id        :integer
#  email                :text(65535)
#  sub                  :text(65535)
#  additional_documents :text(65535)
#  name_mother_tongue   :string(255)
#

require 'rails_helper'

RSpec.describe(Speaker, type: :model) do
  before { create(:cndt2020) }

  describe '#has_accepted_proposal?' do
    subject { speaker.has_accepted_proposal? }

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
