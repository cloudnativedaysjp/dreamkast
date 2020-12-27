
DUMMY_TEXT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

Conference.seed(
  {
    id: 1,
    name: "CloudNative Days Tokyo 2020",
    abbr: "cndt2020",
    status: 2, # closed
    theme: "+Native 〜ともに創るクラウドネイティブの世界〜",
    copyright: '© CloudNative Days Tokyo 2020 (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    about: <<'EOS'
CloudNative Days はコミュニティ、企業、技術者が一堂に会し、クラウドネイティブムーブメントを牽引することを目的としたテックカンファレンスです。
最新の活用事例や先進的なアーキテクチャを学べるのはもちろん、ナレッジの共有やディスカッションの場を通じて登壇者と参加者、参加者同士の繋がりを深め、初心者から熟練者までが共に成長できる機会を提供します。
皆様がクラウドネイティブ技術を適切に選択し、活用し、次のステップに進む手助けになることを願っています。
クラウドネイティブで、未来を共に創造しましょう。
EOS
  },
  {
    id: 2,
    name: "Test Event Winter 2020",
    abbr: "tew2020",
    status: 1, # opened
    theme: "これはTestEventWinter2020のテーマです",
    copyright: '© Test Event Winter 2020 Committee',
    privacy_policy: 'This is Privacy Policy',
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/development/privacy_policy_for_speaker.md')),
    coc: 'This is CoC',
    about: <<'EOS'
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
EOS
  },
  {
    id: 3,
    name: "CloudNative Days Spring 2021 ONLINE",
    abbr: "cndo2021",
    status: 0, # registered
    theme: "ともに踏み出す CloudNative祭",
    copyright: '© CloudNative Days Spring 2021 ONLINE (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cndo2021.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    about: <<'EOS'
    『クラウドネイティブ』って何だっけ？ 私たち自身ずっと考えてきました。
    CNCFによる定義によると、『近代的でダイナミックな環境で、スケーラブルなアプリケーションを構築・実行するための能力を組織にもたらす』のがクラウドネイティブ技術です。
    また、オープンソースでベンダー中立なエコシステムを育成・維持し、このパラダイムの採用を促進したいとも述べられています。
    私たちはこの考えに賛同します。クラウドネイティブ技術を日本にも浸透させるべく、過去数年にわたりイベントを行ってきました。
    
    しかし世の中が大きく変わりつつある昨今。我々はこう考えました。
    『今ならオンラインの特性を生かして、CloudNative Daysをダイナミックな環境でスケーラブルな形に更に進化させられるのではないか？』
    
    オンラインでは、誰でも情報を得ることができ、誰もが発信することもできます。オープンな思想のもとに作られたインターネットには境界がありません。
    そうしたインターネットの成り立ちを思い出し、初心者から達人まで、住んでいる場所を問わず、クラウドネイティブに取り組む人が、
    
    ・今まで参加者だった人が壁を感じずに発信できる
    ・参加者が、これまで以上に多様な視点から学びを得られる
    
    そんな機会を創り出し、登壇者・参加者・イベント主催者といった垣根を超えて、クラウドネイティブ・コミュニティを広げていきたいと考えています。
    CloudNative Days Spring 2021 Onlineでは、クラウドネイティブ技術を通じて培った知見やマインドセットを最大限に活用し、これまでに無かった斬新なイベントを目指しています。
EOS
  }
)

ConferenceDay.seed(
  {id: 1, date: "2020-09-08", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: false},
  {id: 2, date: "2020-09-07", start_time: "19:00", end_time: "21:00", conference_id: 1, internal: true}, #前夜祭
  {id: 3, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 2, internal: false},
  {id: 4, date: "2021-03-11", start_time: "12:00", end_time: "20:00", conference_id: 3, internal: false},
  {id: 5, date: "2021-03-12", start_time: "12:00", end_time: "20:00", conference_id: 3, internal: false},
  )


Industry.seed(
  { id: 1,  conference_id: 1, name: "業界A" },
  { id: 2,  conference_id: 1, name: "業界B" },
  { id: 3,  conference_id: 2, name: "業界C" },
  { id: 4,  conference_id: 2, name: "業界D" },
  { id: 5,  conference_id: 3, name: "業界E" },
  { id: 6,  conference_id: 3, name: "業界F" },
  )


Track.seed(
  { id: 1, number: 1, name: "A", conference_id: 1},
  { id: 2, number: 1, name: "A", conference_id: 2},
  { id: 3, number: 2, name: "B", conference_id: 2},
  { id: 4, number: 1, name: "A", conference_id: 3},
)


TalkCategory.seed(
  { id: 1,  conference_id: 1, name: "Category A"},
  { id: 2,  conference_id: 1, name: "Category B"},
  { id: 3,  conference_id: 2, name: "Category C"},
  { id: 4,  conference_id: 2, name: "Category D"},
  { id: 5,  conference_id: 3, name: "Category E"},
  { id: 6,  conference_id: 3, name: "Category F"}
)

TalkDifficulty.seed(
  { id: 1, conference_id: 1, name: "初級者"},
  { id: 2, conference_id: 1, name: "中級者"},
  { id: 3, conference_id: 1, name: "上級者"},
  { id: 1, conference_id: 2, name: "初級者"},
  { id: 2, conference_id: 2, name: "中級者"},
  { id: 3, conference_id: 2, name: "上級者"},
  { id: 1, conference_id: 3, name: "初級者"},
  { id: 2, conference_id: 3, name: "中級者"},
  { id: 3, conference_id: 3, name: "上級者"},
  )

TalkTime.seed(
  { id: 1, conference_id: 3, time_minutes: 5},
  { id: 2, conference_id: 3, time_minutes: 10},
  { id: 3, conference_id: 3, time_minutes: 15},
  { id: 4, conference_id: 3, time_minutes: 20},
  { id: 5, conference_id: 3, time_minutes: 25},
  { id: 6, conference_id: 3, time_minutes: 30},
  { id: 7, conference_id: 3, time_minutes: 35},
  { id: 8, conference_id: 3, time_minutes: 40}
)

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
  [12, 'Special Sponsor', 'trademark.png'],
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
  { id: 10, talk_id: 65, site: "vimeo", video_id: "442956490", on_air: false, slido_id: ""},
  { id: 11, talk_id: 68, site: "vimeo", video_id: "442956490", on_air: false, slido_id: ""},
)


Link.seed(
  {id: 1, title: "link 1", url: "https://example.com", description: "this is description", conference_id: 1},
  {id: 2, title: "link 2", url: "https://example.com", description: "this is description", conference_id: 1},
  {id: 3, title: "link 3", url: "https://example.com", description: "this is description", conference_id: 1}
)