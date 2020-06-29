require 'rails_helper'

RSpec.describe Talk, type: :model do
  before do
    TalkCategory.create!(
    [
      { name: "CI / CD"},
      { name: "Customizing / Extending"},
      { name: "IoT / Edge"},
      { name: "Microservices / Services Mesh"},
      { name: "ML / GPGPU / HPC"},
      { name: "Networking"},
      { name: "Operation / Monitoring / Logging"},
      { name: "Orchestration"},
      { name: "Runtime"},
      { name: "Security"},
      { name: "Serveless / FaaS"},
      { name: "Storage / Database"},
      { name: "Architecture Design"},
      { name: "Hybrid Cloud / Multi Cloud"},
      { name: "NFV / Edge"},
    ]
    )
    TalkDifficulty.create!(
    [
      { name: "Beginner - 初級者"},
      { name: "Intermediate - 中級者"},
      { name: "Advanced - 上級者"},
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
