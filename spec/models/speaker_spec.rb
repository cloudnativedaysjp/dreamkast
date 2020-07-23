require 'rails_helper'

RSpec.describe Speaker, type: :model do

  before do
    file_path = File.join(Rails.root, 'spec/fixtures/speakers.csv')

    @csv = ActionDispatch::Http::UploadedFile.new(
      filename: File.basename(file_path),
      type: 'image/jpeg',
      tempfile: File.open(file_path)
    )
    Speaker.import(@csv)
  end

  it "is imported 3 speakers and ignored 1 speaker due to invalid record" do
    @speakers = Speaker.all
    expect(@speakers.length).to eq 3
  end

  it "is Takaishi-sensei" do
    @speaker = Speaker.find(1)
    expect(@speaker.name).to eq "高石 諒"
  end

  it "is includes avatar_data in the exported data" do
    all = Speaker.export
    expect(all).to include "ultra-super-takaishi-sensei.png"
  end
end
