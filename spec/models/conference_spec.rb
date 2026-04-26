require 'rails_helper'

RSpec.describe(Conference, type: :model) do
  let!(:cndt2020) { create(:cndt2020) }
  let(:alice) { create(:alice, :on_cndt2020, :offline, conference: cndt2020) }

  describe 'reach_capacity' do
    context 'when 1 user is offline' do
      it 'return false' do
        expect(alice.offline?).to(be_truthy)
        expect(cndt2020.reach_capacity?).to(be_falsey)
      end
    end
    context 'when 2 user is offline' do
      let(:bob) { create(:bob, :on_cndt2020, :offline, conference: cndt2020) }
      it 'return true' do
        expect(alice.offline?).to(be_truthy)
        expect(bob.offline?).to(be_truthy)
        expect(cndt2020.reach_capacity?).to(be_truthy)
      end
    end
    context 'when 1 user is offline and 1 user is online' do
      let(:bob) { create(:bob, :on_cndt2020, conference: cndt2020) }
      it 'return false' do
        expect(alice.offline?).to(be_truthy)
        expect(bob.online?).to(be_truthy)
        expect(cndt2020.reach_capacity?).to(be_falsey)
      end
    end
  end
end
