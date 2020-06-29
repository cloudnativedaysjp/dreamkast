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

  it "has 3 speakers after import " do
    @speakers = Speaker.all
    expect(@speakers.length).to eq 3
  end

  it "is Takaishi-sensei" do
    @speaker = Speaker.find(1)
    expect(@speaker.name).to eq "高石 諒"
  end
end
