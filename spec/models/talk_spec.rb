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


    file_path = File.join(Rails.root, 'spec/fixtures/talks.csv')

    @csv = ActionDispatch::Http::UploadedFile.new(
      filename: File.basename(file_path),
      tempfile: File.open(file_path)
    )
    Talk.import(@csv)
  end

  it "has 4 talks after import " do
    talks = Talk.all
    expect(talks.length).to eq 4
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
    expect(talk.track).to eq "1"
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

  it "is expected track_name" do
    talk = Talk.find(1)
    expect(talk.track_name).to eq "A"
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

  it "is expected talk_number" do
    talk = Talk.find(1)
    expect(talk.talk_number).to eq "1A2"
  end
end
