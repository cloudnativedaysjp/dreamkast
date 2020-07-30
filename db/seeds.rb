# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Conference.all.length == 0
  puts "Adding conference list"
  Conference.create!(
    [
      {id: 1, name: "CloudNative Days Tokyo 2020", abbr: "cndt2020"}
    ]
  )
end

if ConferenceDay.all.length == 0
  puts "Adding conference_day list"
  ConferenceDay.create!(
    [
      {id: 1, date: "2020-09-08", start_time: "12:00", end_time: "20:00", conference_id: 1},
      {id: 2, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1}
    ]
  )
end

if Industry.all.length == 0
  puts "Adding industry list"
  Industry.create!(
    [
      { id: 1, name: "IT関連製造業" },
      { id: 2, name: "電気機器製造業" },
      { id: 3, name: "通信機器関連製造業" },
      { id: 4, name: "電子部品/デバイス/電子回路製造業" },
      { id: 5, name: "自動車/輸送用機器製造業" },
      { id: 6, name: "産業用/事務用機器製造業" },
      { id: 7, name: "食料品/飲料製造業" },
      { id: 8, name: "医薬品/化学製品製造" },
      { id: 9, name: "素材関連製造業" },
      { id: 10, name: "その他の製造業" },
      { id: 11, name: "ソフトウェアベンダー" },
      { id: 12, name: "受託開発/情報処理サービス" },
      { id: 13, name: "組み込み系ソフトウェア" },
      { id: 14, name: "データセンター事業者" },
      { id: 15, name: "クラウド系ベンダー" },
      { id: 16, name: "SaaS系ベンダー" },
      { id: 17, name: "Webサイト制作" },
      { id: 18, name: "Webマーケティング支援" },
      { id: 19, name: "通信事業者" },
      { id: 20, name: "インターネットサービスプロバイダ" },
      { id: 21, name: "その他の情報サービス業" },
      { id: 22, name: "発電事業者" },
      { id: 23, name: "一般送配電事業者" },
      { id: 24, name: "小売電気事業者" },
      { id: 25, name: "ガス/水道業" },
      { id: 26, name: "その他の公益事業関連" },
      { id: 27, name: "商社/販社/卸" },
      { id: 29, name: "小売/流通（IT関連製品外）" },
      { id: 30, name: "金融（銀行/証券/保険など）" },
      { id: 31, name: "運輸/郵便業" },
      { id: 32, name: "放送/出版/メディア" },
      { id: 33, name: "インターネット関連メディア" },
      { id: 34, name: "旅行/ホテル/レジャー業" },
      { id: 35, name: "商社/販社/卸" },
      { id: 36, name: "外食業" },
      { id: 37, name: "広告代理店/PR会社" },
      { id: 38, name: "印刷/DTP" },
      { id: 39, name: "広告制作/デザイン" },
      { id: 40, name: "専門職（弁護士/公認会計士/税理士など）" },
      { id: 41, name: "コンサルティング" },
      { id: 42, name: "その他のサービス業" },
      { id: 43, name: "映像/音楽産業" },
      { id: 44, name: "医療/福祉/病院" },
      { id: 45, name: "農林/水産/鉱業" },
      { id: 46, name: "建設業" },
      { id: 47, name: "住宅/不動産" },
      { id: 48, name: "政府/官公庁/団体" },
      { id: 49, name: "地方自治体" },
      { id: 50, name: "学校/教育機関" },
      { id: 51, name: "研究所（民間/公共）" },
      { id: 52, name: "自営業/独立事業者" },
      { id: 53, name: "学生" },
      { id: 54, name: "勤めていない" },
      { id: 55, name: "該当なし" },
    ]
  )
end

if FormItem.all.length == 0
  puts "Adding form item list"
  FormItem.create!(
    [
      { id: 1, conference_id: 1, name: "IBMからのメールを希望する"},
      { id: 2, conference_id: 1, name: "IBMからの電話を希望する"},
      { id: 3, conference_id: 1, name: "IBMからの郵便を希望する"},
      { id: 4, conference_id: 1, name: "日本マイクロソフト株式会社への個人情報提供に同意する"},
    ]
  )
end

if Track.all.length == 0
  Track.create!(
    [
      { id: 1, number: 1, name: "A", conference_id: 1, movie_url: ""},
      { id: 2, number: 2, name: "B", conference_id: 1, movie_url: ""},
      { id: 3, number: 3, name: "C", conference_id: 1, movie_url: ""},
      { id: 4, number: 4, name: "D", conference_id: 1, movie_url: ""},
      { id: 5, number: 5, name: "E", conference_id: 1, movie_url: ""},
      { id: 6, number: 6, name: "F", conference_id: 1, movie_url: ""},
    ]
  )
end

if TalkCategory.all.length == 0
  puts "Adding talk category list"
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
      { id: 16, name: "組織論"},
      { id: 17, name: "その他"},
      { id: 18, name: "Keynote"},
    ]
  )
end

if TalkDifficulty.all.length == 0
  puts "Adding talk difficulty list"
  TalkDifficulty.create!(
    [
      { id: 1, name: "初級者"},
      { id: 2, name: "中級者"},
      { id: 3, name: "上級者"},
      { id: 4, name: ""},
    ]
  )
end

if (Rails.env.development? || ENV['REVIEW_APP'] == 'true') && Talk.all.length == 0
  file_path = File.join(Rails.root, 'db/talks.csv')

  @csv = ActionDispatch::Http::UploadedFile.new(
    filename: File.basename(file_path),
    tempfile: File.open(file_path)
  )
  Talk.import(@csv)
end

if (Rails.env.development? || ENV['REVIEW_APP'] == 'true') && Speaker.all.length == 0
  file_path = File.join(Rails.root, 'db/speakers.csv')

  @csv = ActionDispatch::Http::UploadedFile.new(
    filename: File.basename(file_path),
    type: 'image/jpeg',
    tempfile: File.open(file_path)
  )
  Speaker.import(@csv)
end

if (Rails.env.development? || ENV['REVIEW_APP'] == 'true') && TalksSpeaker.all.length == 0
  file_path = File.join(Rails.root, 'db/talks_speakers.csv')

  @csv = ActionDispatch::Http::UploadedFile.new(
    filename: File.basename(file_path),
    tempfile: File.open(file_path)
  )
  TalksSpeaker.import(@csv)
end

if Rails.env.development? && Profile.all.length == 0
  Profile.create!(
    [
      {id: 1, first_name: "夢見", last_name: "太郎", industry_id: 1, sub: "a", occupation: "a", department: "a", email: "xxx@example.com", company_name: "aaa", company_address: "xxx", company_email: "yyy@example.com", company_tel: "123-456-7890", position: "president"}
    ]
  )
end

if Rails.env.development? && RegisteredTalk.all.length == 0
  RegisteredTalk.create!(
    [
      { talk_id: 1, profile_id: 1},
      { talk_id: 7, profile_id: 1},
      { talk_id: 14, profile_id: 1},
      { talk_id: 21, profile_id: 1},
      { talk_id: 28, profile_id: 1},
      { talk_id: 35, profile_id: 1},
      { talk_id: 42, profile_id: 1},
    ]
  )
end

if Sponsor.all.length == 0
  puts "Adding sponsor list"
  Sponsor.create!(
    [
      { id: 1,
        name: "スポンサー株式会社",
        conference_id: 1,
        description: "吾輩は猫である。名前はまだ無い。どこで生れたかとんと見当がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。吾輩はここで始めて人間というものを見た。しかもあとで聞くとそれは書生という人間中で一番獰悪な種族であったそうだ。この書生というのは時々我々を捕えて煮て食うという話である。"
      },
      { id: 2,
        name: "Sponsor, inc.",
        conference_id: 1,
        description: "しかしその当時は何という考もなかったから別段恐しいとも思わなかった。ただ彼の掌に載せられてスーと持ち上げられた時何だかフワフワした感じがあったばかりである。掌の上で少し落ちついて書生の顔を見たのがいわゆる人間というものの見始であろう。この時妙なものだと思った感じが今でも残っている。第一毛をもって装飾されべきはずの顔がつるつるしてまるで薬缶だ。その後猫にもだいぶ逢ったがこんな片輪には一度も出会わした事がない。のみならず顔の真中があまりに突起している。"
      },
    ]
  )
end

if SponsorAttachment.all.length == 0
  puts "Adding sponsor attachment list"

  uploader = SponsorAttachmentFileUploader.new(:store)

  logo_image = File.new(Rails.root.join('app/assets/images/trademark.png'))
  uploaded_logo_image = uploader.upload(logo_image)

  pdf = File.new(Rails.root.join('app/assets/seeds/dummy.pdf'))
  uploaded_pdf = uploader.upload(pdf)

  key_image_1 = File.new(Rails.root.join('app/assets/seeds/dummy_sponsor_key_image_1.jpg'))
  uploaded_key_image_1 = uploader.upload(key_image_1)

  key_image_2 = File.new(Rails.root.join('app/assets/seeds/dummy_sponsor_key_image_2.jpg'))
  uploaded_key_image_2 = uploader.upload(key_image_2)

  SponsorAttachment.create!(
    [
      { id: 1,
        sponsor_id: 1,
        type: 'SponsorAttachmentText',
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
      },
      { id: 2,
        sponsor_id: 1,
        type: 'SponsorAttachmentLogoImage',
        file_data: uploaded_logo_image.to_json
      },
      { id: 3,
        sponsor_id: 1,
        type: 'SponsorAttachmentPdf',
        title: 'ダミープレゼンテーション',
        file_data: uploaded_pdf.to_json
      },
      { id: 4,
        sponsor_id: 1,
        type: 'SponsorAttachmentYoutube',
        title: 'CloudNative Days Tokyo パネルトーク #1',
        url: 'https://www.youtube.com/embed/4TJbl4ziebc'
      },
      { id: 5,
        sponsor_id: 1,
        type: 'SponsorAttachmentVimeo',
        url: 'https://player.vimeo.com/video/442956490'
      },
      { id: 6,
        sponsor_id: 1,
        type: 'SponsorAttachmentKeyImage',
        file_data: uploaded_key_image_1.to_json
      },
      { id: 7,
        sponsor_id: 1,
        type: 'SponsorAttachmentKeyImage',
        file_data: uploaded_key_image_2.to_json
      }
    ]
  )
end
