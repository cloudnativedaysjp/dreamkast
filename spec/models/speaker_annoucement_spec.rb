require "rails_helper"

RSpec.describe(SpeakerAnnouncement, type: :model) do
  before do
    @conference = create(:cndt2021)
    @speaker = create(:speaker_mike)
  end
  let(:conf) { @conference }
  let(:speaker) { @speaker }
  let(:default_param) {
    {
      conference_id: conf.id,
      speaker_names: speaker.name,
      publish_time: Time.now,
      body: "test",
      publish: false
    }
  }
  describe "validation" do
    subject { described_class.create(param) }
    context "with valid param" do
      let(:param) { default_param }
      it { expect(subject.id).to(be_truthy) }
    end
    context "with invalid param" do
      context "with nil conference_id" do
        let(:param) {
          default_param[:conference_id] = nil
          default_param
        }
        it { expect(subject.id).to(be_falsey) }
      end
      context "with nil speaker_names" do
        let(:param) {
          default_param[:speaker_names] = nil
          default_param
        }
        it { expect(subject.id).to(be_falsey) }
      end
      context "with nil body" do
        let(:param) {
          default_param[:body] = nil
          default_param
        }
        it { expect(subject.id).to(be_falsey) }
      end
    end
    describe "#published" do
      subject { described_class.published }
      context " when publish is true" do
        before do
          create(:speaker_announcement)
          create(:speaker_announcement, :published)
        end
        it { expect(described_class.all.size).to(eq(2)) }
        it { expect(subject.size).to(eq(1)) }
      end
      context " when publish is false" do
        before do
          create(:speaker_announcement)
          create(:speaker_announcement, :published)
        end
        it { expect(described_class.all.size).to(eq(2)) }
        it { expect(subject.size).to(eq(1)) }
      end
    end
    describe "#format_speaker_namess" do
      pending "wait to impl"
      subject { described_class.create(param).format_speaker_namess }
    end
  end
end
