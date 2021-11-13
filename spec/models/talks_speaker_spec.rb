require "rails_helper"

RSpec.describe(TalksSpeaker, type: :model) do
  before do
    file_path = File.join(Rails.root, "spec/fixtures/talks_speakers.csv")

    @csv = ActionDispatch::Http::UploadedFile.new(
      filename: File.basename(file_path),
      tempfile: File.open(file_path)
    )
    TalksSpeaker.import(@csv)
  end

  it "has 6 relationships after import " do
    @talks_speaker = TalksSpeaker.all
    expect(@talks_speaker.length).to(eq(6))
  end

  it "has valid record" do
    @talks_speaker = TalksSpeaker.all[0]
    expect(@talks_speaker.talk_id).to(eq(1))
    expect(@talks_speaker.speaker_id).to(eq(1))
  end
end
