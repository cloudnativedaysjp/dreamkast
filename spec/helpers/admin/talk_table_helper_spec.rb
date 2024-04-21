require 'rails_helper'

RSpec.describe(Admin::TalkTableHelper, type: :helper) do
  describe '#active_date_tab?' do
    subject { helper.active_date_tab?(conference_day) }

    before do
      conference = create(:cndt2020)
      @day1 = conference.conference_days.first
      @day2 = conference.conference_days.second

      @date = @day1.date.strftime('%Y-%m-%d')
    end

    context 'when conference_day.date is equal to @date' do
      let(:conference_day) { @day1 }
      it { is_expected.to(eq(true)) }
    end

    context 'when conference_day.date is not equal to @date' do
      let(:conference_day) { @day2 }
      it { is_expected.to(eq(false)) }
    end
  end

  describe '#active_track_tab?' do
    subject { helper.active_track_tab?(track) }

    before do
      conference = create(:cndt2020)
      @track_a = conference.tracks.first
      @track_b = conference.tracks.second

      @track_name = @track_a.name
    end

    context 'when track.name is equal to @track_name' do
      let(:track) { @track_a }
      it { is_expected.to(eq(true)) }
    end

    context 'when track.name is not equal to @track_name' do
      let(:track) { @track_b }
      it { is_expected.to(eq(false)) }
    end
  end

  describe '#on_air_url' do
    subject { helper.on_air_url(@talk) }

    before do
      @conference = create(:cndt2020)
      @talk = create(:talk1, conference: @conference)
      create(:video, talk: @talk, on_air:)

      # Rails auto-fills parts of a path parameter using the current page's parameters.
      # In tests, there's no "current page" to use, so url_helper (xxx_path) can't auto-fill without workarounds.
      # Add `event` to `url_options` here to fix paths like in the real app.
      url_options_with_event = helper.url_options.merge(event: @conference.abbr)
      allow(helper).to(receive(:url_options).and_return(url_options_with_event))
    end

    context 'when talk.video.on_air is true' do
      let(:on_air) { true }
      it { is_expected.to(eq('/cndt2020/admin/stop_on_air')) }
    end

    context 'when talk.video.on_air is false' do
      let(:on_air) { false }
      it { is_expected.to(eq('/cndt2020/admin/start_on_air')) }
    end
  end

  describe '#confirm_message' do
    subject { helper.confirm_message(@talk) }

    before do
      conference = create(:cndt2020)
      @talk = create(:talk1, conference:, title: 'Talk Title')
      create(:video, talk: @talk, on_air:)
      speaker1 = create(:speaker_alice, conference:, name: 'Alice')
      speaker2 = create(:speaker_bob, conference:, name: 'Bob')
      create(:talks_speaker, talk: @talk, speaker: speaker1)
      create(:talks_speaker, talk: @talk, speaker: speaker2)
    end

    context 'when talk.video.on_air? is true' do
      let(:on_air) { true }
      it { is_expected.to(eq("Waitingに切り替えます:\nAlice,Bob Talk Title")) }
    end

    context 'when talk.video.on_air? is false' do
      let(:on_air) { false }
      it { is_expected.to(eq("OnAirに切り替えます:\nAlice,Bob Talk Title")) }
    end
  end

  describe '#alert_type' do
    subject { helper.alert_type(message_type) }

    context 'when message_type is notice' do
      let(:message_type) { 'notice' }
      it { is_expected.to(eq('success')) }
    end

    context 'when message_type is danger' do
      let(:message_type) { 'danger' }
      it { is_expected.to(eq('danger')) }
    end

    context 'when message_type is alert' do
      let(:message_type) { 'alert' }
      it { is_expected.to(eq('danger')) }
    end

    context 'when message_type is other' do
      let(:message_type) { 'other' }
      it { is_expected.to(eq('primary')) }
    end
  end

  describe '#already_recorded?' do
    subject { helper.already_recorded?(@talk) }

    before do
      conference = create(:cndt2020)
      @talk = create(:talk1, conference:)
      create(:video, talk: @talk, video_id:)
    end

    context 'when talk.video.video_id is present' do
      let(:video_id) { 'abcdefg' }
      it { is_expected.to(eq(true)) }
    end

    context 'when talk.video.video_id is blank' do
      let(:video_id) { nil }
      it { is_expected.to(eq(false)) }
    end
  end
end
