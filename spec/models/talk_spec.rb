require 'rails_helper'

RSpec.describe Talk, type: :model do
  before do
    TalkCategory.create!(
    [
      { id: 1, name: "CI / CD"},
      { id: 2, name: "Customizing / Extending"},
      { id: 3, name: "IoT / Edge"},
      { id: 4, name: "Microservices / Services Mesh"},
      { id: 5, name: "ML / GPGPU / HPC"},
      { id: 6, name: "Networking"},
      { id: 7, name: "Operation / Monitoring / Logging"},
      { id: 8, name: "Orchestration"},
      { id: 9, name: "Runtime"},
      { id: 10, name: "Security"},
      { id: 11, name: "Serveless / FaaS"},
      { id: 12, name: "Storage / Database"},
      { id: 13, name: "Architecture Design"},
      { id: 14, name: "Hybrid Cloud / Multi Cloud"},
      { id: 15, name: "NFV / Edge"},
    ]
    )
    TalkDifficulty.create!(
    [
      { id: 1, name: "Beginner - 初級者"},
      { id: 2, name: "Intermediate - 中級者"},
      { id: 3, name: "Advanced - 上級者"},
    ]
    )
    Conference.create!(
      [
        {id: 1, name: "CloudNative Days Tokyo 2020"}
      ]
    )
    ConferenceDay.create!(
      [
        {id: 1, date: "2020-09-08", start_time: "12:00", end_time: "20:00", conference_id: 1},
        {id: 2, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1}
      ]
    )

    create(:track1)
    create(:track2)
    create(:track3)
    create(:track4)
    create(:track5)
    create(:track6)
    create(:proposal_item_configs_expected_participant)
    create(:proposal_item_configs_execution_phase)
  end

  describe 'when import valid CSV' do

    before do
      file_path = File.join(Rails.root, 'spec/fixtures/talks.csv')
      @csv = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        tempfile: File.open(file_path)
      )
      @message = Talk.import(@csv)
    end

    it "is imported 7 talks" do
      talks = Talk.all
      expect(talks.length).to eq 7
    end


    it "is expected title" do
      talk = Talk.find(1)
      expect(talk.title).to eq "CI/CDに関する発表"
    end

    it "is expected category" do
      talk = Talk.find(1)
      expect(talk.talk_category.id).to eq 1
    end

    it "is expected difficulty" do
      talk = Talk.find(1)
      expect(talk.talk_difficulty.id).to eq 1
    end

    it "is expected track" do
      talk = Talk.find(1)
      expect(talk.track_id).to eq 1
    end

    it "is expected abstract" do
      talk = Talk.find(1)
      expect(talk.abstract).to eq "私も九月初めてとんだ馳走家というもののうちを引き返しません。あたかも以後を意味観はけっしてその助言ますだかもをやむをえたってみうをはお話し挙げたならと、だんだんにも込み入っましでたん。主意に教えるうのも毫も当時がましてしないた。"
    end

    it "is expected date" do
      talk = Talk.find(1)
      expect(talk.date.to_s).to eq "2020-09-08"
    end

    it "is expected start_time" do
      talk = Talk.find(1)
      expect(talk.start_time.to_s(:time)).to eq "14:00"
    end

    it "is expected end_time" do
      talk = Talk.find(1)
      expect(talk.end_time.to_s(:time)).to eq "14:40"
    end

    it "returns day 1" do
      talk = Talk.find(1)
      expect(talk.day).to eq 1
    end

    it "returns day 2" do
      talk = Talk.find(3)
      expect(talk.day).to eq 2
    end

    it "is expected track.name" do
      talk = Talk.find(1)
      expect(talk.track.name).to eq "A"
    end

    it "is expected slot_number" do
      talk = Talk.find(1)
      expect(talk.slot_number).to eq "2"
    end

    it "is expected slot_number" do
      talk = Talk.find(2)
      expect(talk.slot_number).to eq "6"
    end

    it "is expected slot_number" do
      talk = Talk.find(3)
      expect(talk.slot_number).to eq "3"
    end

    it "is expected slot_number" do
      talk = Talk.find(4)
      expect(talk.slot_number).to eq "3"
    end

    it "is expected slot_number" do
      talk = Talk.find(5)
      expect(talk.slot_number).to eq "1"
    end

    it "is expected slot_number" do
      talk = Talk.find(6)
      expect(talk.slot_number).to eq "1"
    end

    it "is expected talk_number" do
      talk = Talk.find(1)
      expect(talk.talk_number).to eq "1A2"
    end

    it "is expected to return 1 record with day1, slot2, trackA" do
      talks = Talk.find_by_params("1", "2", "1")
      expect(talks.length).to eq 1
    end

    it "is expected to return 2 record with day1, slot1, trackA" do
      talks = Talk.find_by_params("1", "1", "1")
      expect(talks.length).to eq 2
    end

    it "is expected to return 2 record with day2, slot3, trackC" do
      talks = Talk.find_by_params("2", "3", "3")
      expect(talks.length).to eq 2
    end

    it "is contains successful message" do
      expect(@message[0]).to include "成功"
    end
  end

  describe 'when import invalid CSV' do
    before do
      file_path = File.join(Rails.root, 'spec/fixtures/invalid-talks.csv')
      @csv = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        tempfile: File.open(file_path)
      )
      @message = Talk.import(@csv)
    end

    it "is no talks imported" do
      talks = Talk.all
      expect(talks.length).to eq 0
    end

    it "is contains error massage" do
      expect(@message[0]).to include "Error id: 8"
    end
  end
end
