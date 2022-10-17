# == Schema Information
#
# Table name: registered_talks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :integer
#  talk_id    :integer
#

require 'rails_helper'

RSpec.describe(RegisteredTalk, type: :model) do
  describe 'calcurate acquired seats' do
    let(:cndt2020) { create(:cndt2020) }
    let(:profile) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let(:online_ticket) { create(:ticket, :online, conference: cndt2020) }
    let(:offline_ticket) { create(:ticket, :offline, conference: cndt2020) }
    let!(:talk1) { create(:talk1, conference: cndt2020) }
    context 'attend offline' do
      before do
        create(:order, profile:, tickets: [offline_ticket])
        create(:registered_talk, profile:, talk: talk1)
      end

      it 'should count up' do
        expect(talk1.acquired_seats).to(eq(1))
      end
    end

    context 'attend online' do
      before do
        create(:order, profile:, tickets: [online_ticket])
        create(:registered_talk, profile:, talk: talk1)
      end

      it 'should not count up' do
        expect(talk1.acquired_seats).to(eq(0))
      end
    end
  end
end
