# == Schema Information
#
# Table name: chat_messages
#
#  id             :bigint           not null, primary key
#  body           :text(65535)
#  children_count :integer          default(0), not null
#  depth          :integer          default(0), not null
#  lft            :integer          not null
#  message_type   :integer
#  rgt            :integer          not null
#  room_type      :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  conference_id  :bigint           not null
#  parent_id      :integer
#  profile_id     :bigint
#  room_id        :bigint
#  speaker_id     :bigint
#
# Indexes
#
#  index_chat_messages_on_conference_id  (conference_id)
#  index_chat_messages_on_lft            (lft)
#  index_chat_messages_on_parent_id      (parent_id)
#  index_chat_messages_on_profile_id     (profile_id)
#  index_chat_messages_on_rgt            (rgt)
#  index_chat_messages_on_speaker_id     (speaker_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (speaker_id => speakers.id)
#

require 'rails_helper'

RSpec.describe(ChatMessage, type: :model) do
  describe 'validate body' do
    let!(:cndt2020) { create(:cndt2020, :opened) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let(:chat_message) { build(:message_from_alice, body: 'a' * message_length) }

    context 'when body length is greater than 512' do
      let(:message_length) { 513 }

      it 'is invalid' do
        expect(chat_message).to be_invalid
      end
    end

    context 'when body length is equal to 512' do
      let(:message_length) { 512 }

      it 'is valid' do
        expect(chat_message).to be_valid
      end
    end

    context 'when body length is less than 512' do
      let(:message_length) { 511 }

      it 'is valid' do
        expect(chat_message).to be_valid
      end
    end
  end

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

  describe 'get child messages' do
    let!(:cndt2020) { create(:cndt2020, :opened) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:bob) { create(:bob, :on_cndt2020, conference: cndt2020) }
    let!(:parent_message) { create(:messages, :alice, :roomid1, profile: alice) }
    context 'message has child messages' do
      before do
        create(:messages, :bob, :roomid1, :qa, profile: bob, parent_id: parent_message.id)
      end

      it 'should return child messages' do
        expect(parent_message.child_messages.count).to(eq(1))
      end
    end
    context 'message has no child messages' do
      it 'should not return child messages' do
        expect(parent_message.child_messages.count).to(eq(0))
      end
    end
  end
end
