# == Schema Information
#
# Table name: conferences
#
#  id                         :bigint           not null, primary key
#  abbr                       :string(255)
#  about                      :text(65535)
#  attendee_entry             :integer          default("attendee_entry_disabled")
#  brief                      :string(255)
#  capacity                   :integer
#  cfp_result_visible         :boolean          default(FALSE)
#  coc                        :text(65535)
#  committee_name             :string(255)      default("CloudNative Days Committee"), not null
#  conference_status          :string(255)      default("registered")
#  copyright                  :string(255)
#  name                       :string(255)
#  privacy_policy             :text(65535)
#  privacy_policy_for_speaker :text(65535)
#  show_sponsors              :boolean          default(FALSE)
#  show_timetable             :integer          default("show_timetable_disabled")
#  speaker_entry              :integer          default("speaker_entry_disabled")
#  theme                      :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_conferences_on_abbr                        (abbr)
#  index_conferences_on_abbr_and_conference_status  (abbr,conference_status)
#

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
