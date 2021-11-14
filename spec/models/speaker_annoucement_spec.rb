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
      speaker_id: speaker.id,
      speaker_name: speaker.name,
      publish_time: Time.now,
      body: "test",
      publish: false,
      open: false
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
      context "with nil speaker_id" do
        let(:param) {
          default_param[:speaker_id] = nil
          default_param
        }
        it { expect(subject.id).to(be_falsey) }
      end
      context "with nil speaker_name" do
        let(:param) {
          default_param[:speaker_name] = nil
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
  end
end
