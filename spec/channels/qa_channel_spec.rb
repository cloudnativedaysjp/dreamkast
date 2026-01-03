require 'rails_helper'

RSpec.describe QaChannel, type: :channel do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }

  before do
    stub_connection
  end

  describe '#subscribed' do
    context 'with valid talk_id' do
      it 'successfully subscribes' do
        subscribe(talk_id: talk.id)
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("qa_talk_#{talk.id}")
      end
    end

    context 'without talk_id' do
      it 'rejects subscription' do
        subscribe(talk_id: nil)
        expect(subscription).to be_rejected
      end
    end

    context 'with non-existent talk_id' do
      it 'rejects subscription' do
        subscribe(talk_id: 99999)
        expect(subscription).to be_rejected
      end
    end

    context 'with talk without conference_id' do
      let!(:invalid_talk) do
        # 既存のtalkを一時的にconference_idをnilに設定
        talk.update_column(:conference_id, nil)
        talk
      end

      after do
        # テスト後に元に戻す
        invalid_talk.update_column(:conference_id, conference.id) if invalid_talk.persisted?
      end

      it 'rejects subscription' do
        subscribe(talk_id: invalid_talk.id)
        expect(subscription).to be_rejected
      end
    end
  end
end
