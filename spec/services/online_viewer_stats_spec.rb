require 'rails_helper'

RSpec.describe OnlineViewerStats do
  let(:conference) { instance_double(Conference, talks: double(pluck: talk_ids)) }
  let(:talk_ids) { [101, 102, 103] }
  let(:scoped_relation) { double('TrackViewer relation') }

  subject(:stats) { described_class.new(conference) }

  describe '#unique_viewers_count' do
    context 'when talk_ids exist and dkui is reachable' do
      it 'returns DISTINCT profile_id count scoped to the conference talks' do
        expect(TrackViewer).to receive(:for_talk_ids).with(talk_ids).and_return(scoped_relation)
        expect(scoped_relation).to receive(:distinct).and_return(scoped_relation)
        expect(scoped_relation).to receive(:count).with(:profile_id).and_return(42)

        expect(stats.unique_viewers_count).to eq(42)
      end
    end

    context 'when the conference has no talks' do
      let(:talk_ids) { [] }

      it 'returns nil without querying TrackViewer' do
        expect(TrackViewer).not_to receive(:for_talk_ids)
        expect(stats.unique_viewers_count).to be_nil
      end
    end

    context 'when dkui DB is unreachable' do
      it 'returns nil and logs a warning' do
        allow(TrackViewer).to receive(:for_talk_ids).and_raise(ActiveRecord::StatementInvalid, 'boom')
        expect(Rails.logger).to receive(:warn).with(/OnlineViewerStats.*unavailable/)

        expect(stats.unique_viewers_count).to be_nil
      end
    end
  end

  describe '#viewer_counts_by_talk' do
    context 'when talk_ids exist and dkui is reachable' do
      it 'returns a Hash keyed by talk_id with DISTINCT profile_id counts' do
        expect(TrackViewer).to receive(:for_talk_ids).with(talk_ids).and_return(scoped_relation)
        expect(scoped_relation).to receive(:group).with(:talk_id).and_return(scoped_relation)
        expect(scoped_relation).to receive(:distinct).and_return(scoped_relation)
        expect(scoped_relation).to receive(:count).with(:profile_id).and_return({ 101 => 10, 102 => 5 })

        expect(stats.viewer_counts_by_talk).to eq({ 101 => 10, 102 => 5 })
      end
    end

    context 'when the conference has no talks' do
      let(:talk_ids) { [] }

      it 'returns nil' do
        expect(stats.viewer_counts_by_talk).to be_nil
      end
    end

    context 'when dkui DB is unreachable' do
      it 'returns nil and swallows Mysql2::Error' do
        allow(TrackViewer).to receive(:for_talk_ids).and_raise(Mysql2::Error, 'connection refused')
        allow(Rails.logger).to receive(:warn)

        expect(stats.viewer_counts_by_talk).to be_nil
      end
    end
  end
end
