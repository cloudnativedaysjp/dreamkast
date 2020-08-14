FactoryBot.define do
  factory :sponsor_attachment do
    sponsor { nil }
    type { "" }
    url { "MyString" }
    text { "MyText" }
    link { "MyString" }
    public { false }
  end
end
