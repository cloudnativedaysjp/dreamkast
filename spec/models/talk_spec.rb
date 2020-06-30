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
    @talks = Talk.all
    expect(@talks.length).to eq 4
  end


  it "has valid record" do
    @talk = Talk.all[0]
    expect(@talk.title).to eq "CI/CDに関する発表"
  end
end
