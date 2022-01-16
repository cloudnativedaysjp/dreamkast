require 'rails_helper'

RSpec.describe(SpeakerAnnouncement, type: :model) do
  let!(:conf) { create(:cndt2020) }
  let!(:speaker) { create(:speaker_mike) }
  let!(:default_param) {
    {
      conference_id: conf.id,
      publish_time: Time.now,
      body: 'test',
      publish: false
    }
  }
  describe 'validation' do
    subject { described_class.create(param) }
    context 'with valid param' do
      let(:param) { default_param }
      it { expect(subject.id).to(be_truthy) }
    end

    context 'with invalid param' do
      context 'with nil conference_id' do
        let(:param) {
          default_param[:conference_id] = nil
          default_param
        }
        it { expect(subject.id).to(be_falsey) }
      end

      context 'with nil body' do
        let(:param) {
          default_param[:body] = nil
          default_param
        }
        it { expect(subject.id).to(be_falsey) }
      end
    end
    describe '#published' do
      subject { described_class.published }
      context ' when publish is true' do
        before do
          create(:speaker_announcement, conference: conf)
          create(:speaker_announcement, :published, conference: conf)
        end
        it { expect(described_class.all.size).to(eq(2)) }
        it { expect(subject.size).to(eq(1)) }
      end
      context ' when publish is false' do
        before do
          create(:speaker_announcement, conference: conf)
          create(:speaker_announcement, :published, conference: conf)
        end
        it { expect(described_class.all.size).to(eq(2)) }
        it { expect(subject.size).to(eq(1)) }
      end
    end

    describe '#find_by_speaker' do
      subject { described_class.find_by_speaker(speaker.id) }
      before do
        create(:speaker_announcement, :published, speakers: [create(:speaker_alice)])
        create(:speaker_announcement, :speaker_mike, speakers: [speaker])
      end
      it 'find ones related by mike' do
        expect(SpeakerAnnouncement.all.size).to(eq(2))
        expect(subject.size).to(eq(1))
        expect(subject.first.body).to(eq('test announcement for mike'))
      end
    end

    describe '#accepted_announcements' do
      subject { described_class.accepted_announcements }
      before { create(:speaker_announcement, :only_accepted, speakers: [speaker]) }

      context 'speaker has accepted proposal' do
        it 'find one announcement' do
          expect(SpeakerAnnouncement.all.size).to(eq(1))
          expect(subject.size).to(eq(1))
        end
      end
    end

    describe '#speaker_names' do
      context 'when to all speakers' do
        let!(:announce) { create(:speaker_announcement, :published_all) }
        it { expect(announce.speaker_names).to(eq('全員')) }
      end

      context 'when to cfp accepted speakers' do
        let!(:announce) { create(:speaker_announcement, :only_accepted) }
        it { expect(announce.speaker_names).to(eq('CFP採択者')) }
      end

      context 'when to speaker alice' do
        let!(:announce) { create(:speaker_announcement, :published, speakers: [create(:speaker_alice)]) }
        it { expect(announce.speaker_names).to(eq('Alice')) }
      end
    end
  end
end
