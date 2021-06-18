FactoryBot.define do
  factory :track, class: Track do
    video_platform { "vimeo" }
  end

  ["A", "B", "C", "D", "E", "F", "G"].each_with_index do |value, index|
    factory "cndo_track#{index + 1}".to_sym, class: Track do
      id { index + 10 }
      number { index + 1 }
      name { value }
      conference_id { 2 }
      video_platform { "vimeo" }
      video_id { "video_7" }
    end
  end
end