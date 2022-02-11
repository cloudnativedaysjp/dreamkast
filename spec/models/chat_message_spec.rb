require 'rails_helper'

RSpec.describe(ChatMessage, type: :model) do
  describe 'get message count' do
    context 'with opened conference' do
      before do
        create(:talk1, conference: cndt2020)
        create_list(:messages, 10, :alice, :roomid1, profile: alice)
        create_list(:messages, 12, :bob, :roomid2, profile: bob)
      end
      let!(:cndt2020) { create(:cndt2020, :opened) }
      let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
      let!(:bob) { create(:bob, :on_cndt2020, conference: cndt2020) }

      context 'should return correct count' do
        it { expect(ChatMessage.counts.find_by(room_id: 1, conference_id: 1).count).to(eq(10)) }
        it { expect(ChatMessage.counts.find_by(room_id: 2, conference_id: 1).count).to(eq(12)) }
      end
    end
    context 'with archived conference' do
      let!(:cndt2020) { create(:cndt2020, :archived) }

      context 'should not return message count' do
        it { expect(ChatMessage.counts.find_by(room_id: 1, conference_id: 1)).to(be(nil)) }
        it { expect(ChatMessage.counts.find_by(room_id: 2, conference_id: 1)).to(be(nil)) }
      end
    end
  end
end
