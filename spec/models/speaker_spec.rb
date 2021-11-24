# == Schema Information
#
# Table name: speakers
#
#  id                   :bigint           not null, primary key
#  additional_documents :text(65535)
#  avatar_data          :text(65535)
#  company              :string(255)
#  email                :text(65535)
#  job_title            :string(255)
#  name                 :string(255)
#  name_mother_tongue   :string(255)
#  profile              :text(65535)
#  sub                  :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  conference_id        :integer
#  github_id            :string(255)
#  twitter_id           :string(255)
#
require "rails_helper"

RSpec.describe(Speaker, type: :model) do
  before do
    create(:cndt2020)
  end

  describe "with valid CSV" do
    before do
      file_path = File.join(Rails.root, "spec/fixtures/speakers.csv")

      @csv = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        type: "image/jpeg",
        tempfile: File.open(file_path)
      )
      @message = Speaker.import(@csv)
    end

    it "is imported 3 speakers" do
      @speakers = Speaker.all
      expect(@speakers.length).to(eq(3))
    end

    it "is Takaishi-sensei" do
      @speaker = Speaker.find(1)
      expect(@speaker.name).to(eq("高石 諒"))
    end

    it "is includes avatar_data in the exported data" do
      all = Speaker.export
      expect(all).to(include("ultra-super-takaishi-sensei.png"))
    end

    it "is no message returns" do
      expect(@message.size).to(eq(0))
    end

    describe "Update CSV" do
      before do
        file_path = File.join(Rails.root, "spec/fixtures/modified_speakers.csv")

        @csv = ActionDispatch::Http::UploadedFile.new(
          filename: File.basename(file_path),
          type: "image/jpeg",
          tempfile: File.open(file_path)
        )
        @message = Speaker.import(@csv)
      end

      it "is imported 4 speakers" do
        @speakers = Speaker.all
        expect(@speakers.length).to(eq(4))
      end

      it "is modified speaker" do
        @speaker = Speaker.find(3)
        expect(@speaker.name).to(eq("変更され太郎"))
      end

      it "is added speaker" do
        @speaker = Speaker.find(4)
        expect(@speaker.name).to(eq("追加され太郎"))
      end

      it "is speaker remain unchanged" do
        @speaker = Speaker.find(2)
        expect(@speaker.name).to(eq("講演し太郎2"))
      end
    end
  end

  describe "with invalid CSV" do
    before do
      file_path = File.join(Rails.root, "spec/fixtures/invalid-speakers.csv")

      @csv = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        type: "image/jpeg",
        tempfile: File.open(file_path)
      )
      @message = Speaker.import(@csv)
    end

    it "is no speakers imported" do
      @speakers = Speaker.all
      expect(@speakers.length).to(eq(0))
    end

    it "is 1 message returns" do
      expect(@message[0]).to(include("id: 4"))
    end
  end
end
