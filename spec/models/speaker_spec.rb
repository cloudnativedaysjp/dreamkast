require 'rails_helper'

RSpec.describe Speaker, type: :model do

  describe 'with valid CSV' do
    before do
      file_path = File.join(Rails.root, 'spec/fixtures/speakers.csv')
  
      @csv = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        type: 'image/jpeg',
        tempfile: File.open(file_path)
      )
      @message = Speaker.import(@csv)
    end

    it "is imported 3 speakers" do
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

    it "is no message returns" do
      expect(@message.size).to eq 0
    end
  end

  describe 'with invalid CSV' do
    before do
      file_path = File.join(Rails.root, 'spec/fixtures/invalid-speakers.csv')
  
      @csv = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        type: 'image/jpeg',
        tempfile: File.open(file_path)
      )
      @message = Speaker.import(@csv)
    end

    it "is no speakers imported" do
      @speakers = Speaker.all
      expect(@speakers.length).to eq 0
    end
  
    it "is 1 message returns" do
      expect(@message[0]).to include "id: 4"
    end
  end

end
