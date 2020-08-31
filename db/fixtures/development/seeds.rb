DUMMY_TEXT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'


csv = CSV.read(File.join(Rails.root, 'db/talks.csv'), headers: true)
Talk.seed(csv.map(&:to_hash))

csv = CSV.read(File.join(Rails.root, 'db/speakers.csv'), headers: true)
Speaker.seed(csv.map(&:to_hash))

csv = CSV.read(File.join(Rails.root, 'db/talks_speakers.csv'), headers: true)
csv.each do |row|
  TalksSpeaker.seed(:talk_id, :speaker_id) do |t|
    h = row.to_hash
    t.talk_id = h["talk_id"]
    t.speaker_id = h["speaker_id"]
  end
end

Profile.seed(
  {
    id: 1,
    first_name: "夢見",
    last_name: "太郎",
    industry_id: 1,
    sub: "a",
    occupation: "a",
    department: "a",
    email: "xxx@example.com",
    company_name: "aaa",
    company_address: "xxx",
    company_email: "yyy@example.com",
    company_tel: "123-456-7890",
    position: "president"
  }
)

RegisteredTalk.seed(
  { id: 1, talk_id: 1, profile_id: 1},
  { id: 2, talk_id: 7, profile_id: 1},
  { id: 3, talk_id: 14, profile_id: 1},
  { id: 4, talk_id: 21, profile_id: 1},
  { id: 5, talk_id: 28, profile_id: 1},
  { id: 6, talk_id: 35, profile_id: 1},
  { id: 7, talk_id: 42, profile_id: 1}
)

Sponsor.seed(
  { id: 1,
    name: "スポンサー株式会社",
    conference_id: 1,
    description: "吾輩は猫である。名前はまだ無い。どこで生れたかとんと見当がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。吾輩はここで始めて人間というものを見た。しかもあとで聞くとそれは書生という人間中で一番獰悪な種族であったそうだ。この書生というのは時々我々を捕えて煮て食うという話である。",
    url: "https://example.com/"
  },
  { id: 2,
    name: "Sponsor, inc.",
    conference_id: 1,
    description: "しかしその当時は何という考もなかったから別段恐しいとも思わなかった。ただ彼の掌に載せられてスーと持ち上げられた時何だかフワフワした感じがあったばかりである。掌の上で少し落ちついて書生の顔を見たのがいわゆる人間というものの見始であろう。この時妙なものだと思った感じが今でも残っている。第一毛をもって装飾されべきはずの顔がつるつるしてまるで薬缶だ。その後猫にもだいぶ逢ったがこんな片輪には一度も出会わした事がない。のみならず顔の真中があまりに突起している。",
    url: "https://example.com/"
  },
  { id: 3,
    name: "プラチナスポンサー株式会社",
    conference_id: 1,
    description: "しかしその当時は何という考もなかったから別段恐しいとも思わなかった。ただ彼の掌に載せられてスーと持ち上げられた時何だかフワフワした感じがあったばかりである。掌の上で少し落ちついて書生の顔を見たのがいわゆる人間というものの見始であろう。この時妙なものだと思った感じが今でも残っている。第一毛をもって装飾されべきはずの顔がつるつるしてまるで薬缶だ。その後猫にもだいぶ逢ったがこんな片輪には一度も出会わした事がない。のみならず顔の真中があまりに突起している。",
    url: "https://example.com/"
  },
  {
    id: 4,
    name: "スポンサー4",
    conference_id: 1,
    url: "https://example.com/"
  },
  {
    id: 5,
    name: "スポンサー5",
    conference_id: 1,
    url: "https://example.com/"
  },
  {
    id: 6,
    name: "スポンサー6",
    conference_id: 1,
    url: "https://example.com/"
  },
  {
    id: 7,
    name: "Special Sponsor",
    conference_id: 1,
    url: "https://example.com/"
  }
)

SponsorType.seed(
  { id: 1,
    conference_id: 1,
    name: "Diamond",
    order: 2,
  },
  { id: 2,
    conference_id: 1,
    name: "Platinum",
    order: 3,
  },
  { id: 3,
    conference_id: 1,
    name: "Booth",
    order: 4,
  },
  { id: 4,
    conference_id: 1,
    name: "Special Collaboration",
    order: 1,
  }
)

[
  [1, 'Diamond', 'スポンサー株式会社'],
  [2, 'Platinum', 'Sponsor, inc.'],
  [4, 'Booth', 'スポンサー株式会社', true],
  [5, 'Booth', 'プラチナスポンサー株式会社', true],
  [6, 'Booth', 'スポンサー4', true],
  [7, 'Booth', 'スポンサー5', true],
  [8, 'Booth', 'スポンサー6', true],
  [9, 'Special Collaboration', 'Special Sponsor', true],
].each do |sponsors_sponsor_type|
  id = sponsors_sponsor_type[0]
  sponsor_type = SponsorType.find_by(name: sponsors_sponsor_type[1])
  sponsor = Sponsor.find_by(name: sponsors_sponsor_type[2])
  SponsorsSponsorType.seed({id: id, sponsor_type_id: sponsor_type.id, sponsor_id: sponsor.id})

  if sponsors_sponsor_type[1] == 'Booth'
    Booth.seed(:conference_id, :sponsor_id) do |s|
      s.conference_id = 1
      s.sponsor_id = sponsor.id
      s.published = sponsors_sponsor_type[3]
    end
  end
end

uploader = SponsorAttachmentFileUploader.new(:store)

logo_image = File.new(Rails.root.join('app/assets/images/trademark.png'))
uploaded_logo_image = uploader.upload(logo_image)

pdf = File.new(Rails.root.join('app/assets/seeds/dummy.pdf'))
uploaded_pdf = uploader.upload(pdf)

key_image_1 = File.new(Rails.root.join('app/assets/seeds/dummy_sponsor_key_image_1.jpg'))
uploaded_key_image_1 = uploader.upload(key_image_1)

key_image_2 = File.new(Rails.root.join('app/assets/seeds/dummy_sponsor_key_image_2.jpg'))
uploaded_key_image_2 = uploader.upload(key_image_2)

[
  [1, 'スポンサー株式会社', 'trademark.png'],
  [2, 'Sponsor, inc.', 'trademark.png'],
  [3, 'プラチナスポンサー株式会社', 'trademark.png'],
  [4, 'スポンサー4', 'trademark.png'],
  [5, 'スポンサー5', 'trademark.png'],
  [6, 'スポンサー6', 'trademark.png'],
  [7, 'Special Sponsor', 'trademark.png'],
].each do |logo|
  SponsorAttachment.seed(
    { id: logo[0],
      sponsor_id: Sponsor.find_by(name: logo[1]).id,
      type: 'SponsorAttachmentLogoImage',
      url: logo[2]
    }
  )
end

SponsorAttachment.seed(
  { id: 7,
    sponsor_id: 1,
    type: 'SponsorAttachmentText',
    text: DUMMY_TEXT
  },
  { id: 8,
    sponsor_id: 1,
    type: 'SponsorAttachmentPdf',
    title: 'ダミープレゼンテーション',
    file_data: uploaded_pdf.to_json
  },
  { id: 9,
    sponsor_id: 1,
    type: 'SponsorAttachmentVimeo',
    url: 'https://player.vimeo.com/video/442956490'
  },
  { id: 10,
    sponsor_id: 1,
    type: 'SponsorAttachmentKeyImage',
    file_data: uploaded_key_image_1.to_json
  },
  { id: 11,
    sponsor_id: 1,
    type: 'SponsorAttachmentKeyImage',
    file_data: uploaded_key_image_2.to_json
  }
)

Video.seed(
  { id: 1, talk_id: 1, site: "vimeo", video_id: "444387842", on_air: true, slido_id: "styoi2cj"},
  { id: 2, talk_id: 2, site: "vimeo", video_id: "442363621", on_air: true, slido_id: "3jtfhpkv"},
  { id: 3, talk_id: 3, site: "vimeo", video_id: "334092219", on_air: true, slido_id: "1qev4oju"},
  { id: 4, talk_id: 4, site: "vimeo", video_id: "410005892", on_air: true, slido_id: "tl9tdhei"},
  { id: 5, talk_id: 5, site: "vimeo", video_id: "303648115", on_air: true, slido_id: "raigsrzj"},
  { id: 6, talk_id: 6, site: "vimeo", video_id: "417159783", on_air: true, slido_id: "maxjcvxp"},
  { id: 7, talk_id: 7, site: "vimeo", video_id: "442385897", on_air: false, slido_id: "styoi2cj"},
  { id: 8, talk_id: 8, site: "vimeo", video_id: "444712888", on_air: false, slido_id: "3jtfhpkv"},
  { id: 9, talk_id: 9, site: "vimeo", video_id: "443856794", on_air: false, slido_id: "1qev4oju"},
)
