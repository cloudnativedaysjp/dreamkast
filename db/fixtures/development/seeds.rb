
DUMMY_TEXT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

Conference.seed(
  {
    id: 1,
    name: "CloudNative Days Tokyo 2020",
    abbr: "cndt2020",
    status: 2, # closed
    speaker_entry: 0,
    attendee_entry: 0,
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
    name: "CloudNative Days Spring 2021 ONLINE",
    abbr: "cndo2021",
    status: 0, # registered
    speaker_entry: 1, # enabled
    attendee_entry: 0, # disabled
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
  },
  {
    id: 3,
    name: "CI/CD Conference 2021 by CloudNative Days",
    abbr: "cicd2021",
    status: 0,
    speaker_entry: 1,
    attendee_entry: 0,
    theme: "Continuous 〜 技術を知り、試し、取り入れる 〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cicd2021.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    about: <<'EOS'
CI/CD Conferenceは、CI/CDに特化したテックカンファレンスです。『技術を知り、試して、取り入れる』のコンセプトのもと、参加者が優れたCI/CDの知見を取り入れ、改善を行っていけるイベントを目指しています。そして、ゆくゆくは参加者が登壇者となり、他の人に知見を共有していける、Continuousなイベントでありたいと思っています。
EOS
  },
  {
    id: 10,
    name: "Test Event Winter 2020",
    abbr: "tew2020",
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
)

ConferenceDay.seed(
  {id: 1, date: "2020-09-08", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: false},
  {id: 2, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: false},
  {id: 3, date: "2020-09-02", start_time: "19:00", end_time: "21:00", conference_id: 1, internal: true}, #rejekts
  {id: 4, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: true}, #CM
  {id: 5, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: true}, #Mini session

  {id: 6, date: "2021-03-11", start_time: "12:00", end_time: "20:00", conference_id: 2, internal: false},
  {id: 7, date: "2021-03-12", start_time: "12:00", end_time: "20:00", conference_id: 2, internal: false},
  {id: 8, date: "2021-02-26", start_time: "19:00", end_time: "21:00", conference_id: 2, internal: true}, #Pre event

  
  {id: 9, date: "2021-09-03", start_time: "13:00", end_time: "19:00", conference_id: 3, internal: false},
  {id: 10, date: "2021-08-05", start_time: "19:00", end_time: "21:00", conference_id: 3, internal: true}, #Pre event
)

Industry.seed(
  { id: 1,  conference_id: 1, name: "IT関連製造業" },
  { id: 2,  conference_id: 1, name: "電気機器製造業" },
  { id: 3,  conference_id: 1, name: "通信機器関連製造業" },
  { id: 4,  conference_id: 1, name: "電子部品/デバイス/電子回路製造業" },
  { id: 5,  conference_id: 1, name: "自動車/輸送用機器製造業" },
  { id: 6,  conference_id: 1, name: "産業用/事務用機器製造業" },
  { id: 7,  conference_id: 1, name: "食料品/飲料製造業" },
  { id: 8,  conference_id: 1, name: "医薬品/化学製品製造" },
  { id: 9,  conference_id: 1, name: "素材関連製造業" },
  { id: 10, conference_id: 1, name: "その他の製造業" },
  { id: 11, conference_id: 1, name: "ソフトウェアベンダー" },
  { id: 12, conference_id: 1, name: "受託開発/情報処理サービス" },
  { id: 13, conference_id: 1, name: "組み込み系ソフトウェア" },
  { id: 14, conference_id: 1, name: "データセンター事業者" },
  { id: 15, conference_id: 1, name: "クラウド系ベンダー" },
  { id: 16, conference_id: 1, name: "SaaS系ベンダー" },
  { id: 17, conference_id: 1, name: "Webサイト制作" },
  { id: 18, conference_id: 1, name: "Webマーケティング支援" },
  { id: 19, conference_id: 1, name: "通信事業者" },
  { id: 20, conference_id: 1, name: "インターネットサービスプロバイダ" },
  { id: 21, conference_id: 1, name: "その他の情報サービス業" },
  { id: 22, conference_id: 1, name: "発電事業者" },
  { id: 23, conference_id: 1, name: "一般送配電事業者" },
  { id: 24, conference_id: 1, name: "小売電気事業者" },
  { id: 25, conference_id: 1, name: "ガス/水道業" },
  { id: 26, conference_id: 1, name: "その他の公益事業関連" },
  { id: 27, conference_id: 1, name: "商社/販社/卸" },
  { id: 29, conference_id: 1, name: "小売/流通（IT関連製品外）" },
  { id: 30, conference_id: 1, name: "金融（銀行/証券/保険など）" },
  { id: 31, conference_id: 1, name: "運輸/郵便業" },
  { id: 32, conference_id: 1, name: "放送/出版/メディア" },
  { id: 33, conference_id: 1, name: "インターネット関連メディア" },
  { id: 34, conference_id: 1, name: "旅行/ホテル/レジャー業" },
  { id: 35, conference_id: 1, name: "商社/販社/卸" },
  { id: 36, conference_id: 1, name: "外食業" },
  { id: 37, conference_id: 1, name: "広告代理店/PR会社" },
  { id: 38, conference_id: 1, name: "印刷/DTP" },
  { id: 39, conference_id: 1, name: "広告制作/デザイン" },
  { id: 40, conference_id: 1, name: "専門職（弁護士/公認会計士/税理士など）" },
  { id: 41, conference_id: 1, name: "コンサルティング" },
  { id: 42, conference_id: 1, name: "その他のサービス業" },
  { id: 43, conference_id: 1, name: "映像/音楽産業" },
  { id: 44, conference_id: 1, name: "医療/福祉/病院" },
  { id: 45, conference_id: 1, name: "農林/水産/鉱業" },
  { id: 46, conference_id: 1, name: "建設業" },
  { id: 47, conference_id: 1, name: "住宅/不動産" },
  { id: 48, conference_id: 1, name: "政府/官公庁/団体" },
  { id: 49, conference_id: 1, name: "地方自治体" },
  { id: 50, conference_id: 1, name: "学校/教育機関" },
  { id: 51, conference_id: 1, name: "研究所（民間/公共）" },
  { id: 52, conference_id: 1, name: "自営業/独立事業者" },
  { id: 53, conference_id: 1, name: "学生" },
  { id: 54, conference_id: 1, name: "勤めていない" },
  { id: 55, conference_id: 1, name: "該当なし" }
)

FormItem.seed(
  { id: 1, conference_id: 1, name: "IBMからのメールを希望する"},
  { id: 2, conference_id: 1, name: "IBMからの電話を希望する"},
  { id: 3, conference_id: 1, name: "IBMからの郵便を希望する"},
  { id: 4, conference_id: 1, name: "日本マイクロソフト株式会社への個人情報提供に同意する"},
  { id: 5, conference_id: 2, name: "日本マイクロソフト株式会社への個人情報提供に同意する"}
)


Track.seed(
  { id: 1, number: 1, name: "A", conference_id: 1},
  { id: 2, number: 2, name: "B", conference_id: 1},
  { id: 3, number: 3, name: "C", conference_id: 1},
  { id: 4, number: 4, name: "D", conference_id: 1},
  { id: 5, number: 5, name: "E", conference_id: 1},
  { id: 6, number: 6, name: "F", conference_id: 1},
  { id: 10, number: 1, name: "A", conference_id: 2, video_platform: "vimeo", video_id: "aaaaaa"},
  { id: 11, number: 2, name: "B", conference_id: 2, video_platform: "vimeo", video_id: "bbbbbb"},
  { id: 12, number: 3, name: "C", conference_id: 2, video_platform: "vimeo", video_id: "cccccc"},
  { id: 13, number: 4, name: "D", conference_id: 2, video_platform: "vimeo", video_id: "dddddd"},
  { id: 14, number: 5, name: "E", conference_id: 2, video_platform: "vimeo", video_id: "eeeeee"},
  { id: 15, number: 6, name: "F", conference_id: 2, video_platform: "vimeo", video_id: "ffffff"},
  { id: 16, number: 7, name: "G", conference_id: 2, video_platform: "vimeo", video_id: "gggggg"},
  { id: 17, number: 1, name: "A", conference_id: 3, video_platform: "vimeo", video_id: "ffffff"},
  { id: 18, number: 2, name: "B", conference_id: 3, video_platform: "vimeo", video_id: "gggggg"},
  { id: 19, number: 3, name: "C", conference_id: 3, video_platform: "vimeo", video_id: "gggggg"},
)


TalkCategory.seed(
  { id: 1,  conference_id: 1, name: "CI / CD"},
  { id: 2,  conference_id: 1, name: "Customizing / Extending"},
  { id: 3,  conference_id: 1, name: "IoT / Edge"},
  { id: 4,  conference_id: 1, name: "Microservices / Services Mesh"},
  { id: 5,  conference_id: 1, name: "ML / GPGPU / HPC"},
  { id: 6,  conference_id: 1, name: "Networking"},
  { id: 7,  conference_id: 1, name: "Operation / Monitoring / Logging"},
  { id: 8,  conference_id: 1, name: "Orchestration"},
  { id: 9,  conference_id: 1, name: "Runtime"},
  { id: 10, conference_id: 1, name: "Security"},
  { id: 11, conference_id: 1, name: "Serveless / FaaS"},
  { id: 12, conference_id: 1, name: "Storage / Database"},
  { id: 13, conference_id: 1, name: "Architecture Design"},
  { id: 14, conference_id: 1, name: "Hybrid Cloud / Multi Cloud"},
  { id: 15, conference_id: 1, name: "NFV / Edge"},
  { id: 16, conference_id: 1, name: "組織論"},
  { id: 17, conference_id: 1, name: "その他"},
  { id: 18, conference_id: 1, name: "Keynote"},

  { id: 19, conference_id: 2, name: "CI / CD"},
  { id: 20, conference_id: 2, name: "Customizing / Extending"},
  { id: 21, conference_id: 2, name: "IoT / Edge"},
  { id: 22, conference_id: 2, name: "Microservices / Services Mesh"},
  { id: 23, conference_id: 2, name: "ML / GPGPU / HPC"},
  { id: 24, conference_id: 2, name: "Networking"},
  { id: 25, conference_id: 2, name: "Operation / Monitoring / Logging"},
  { id: 26, conference_id: 2, name: "Orchestration"},
  { id: 27, conference_id: 2, name: "Runtime"},
  { id: 28, conference_id: 2, name: "Security"},
  { id: 29, conference_id: 2, name: "Serveless / FaaS"},
  { id: 30, conference_id: 2, name: "Storage / Database"},
  { id: 31, conference_id: 2, name: "Architecture Design"},
  { id: 32, conference_id: 2, name: "Hybrid Cloud / Multi Cloud"},
  { id: 33, conference_id: 2, name: "NFV / Edge"},
  { id: 34, conference_id: 2, name: "組織論"},
  { id: 35, conference_id: 2, name: "その他"},
  { id: 36, conference_id: 2, name: "Keynote"}
)

TalkDifficulty.seed(
  { id: 1, conference_id: 1, name: "初級者"},
  { id: 2, conference_id: 1, name: "中級者"},
  { id: 3, conference_id: 1, name: "上級者"},
  { id: 4, conference_id: 1, name: ""},
  { id: 11, conference_id: 2, name: "初級者"},
  { id: 12, conference_id: 2, name: "中級者"},
  { id: 13, conference_id: 2, name: "上級者"},
  { id: 21, conference_id: 3, name: "初級者"},
  { id: 22, conference_id: 3, name: "中級者"},
  { id: 23, conference_id: 3, name: "上級者"},
  { id: 27, conference_id: 10, name: "初級者"},
  { id: 28, conference_id: 10, name: "中級者"},
  { id: 29, conference_id: 10, name: "上級者"},
  )

TalkTime.seed(
  { id: 1, conference_id: 2, time_minutes: 5},
  { id: 2, conference_id: 2, time_minutes: 10},
  { id: 3, conference_id: 2, time_minutes: 15},
  { id: 4, conference_id: 2, time_minutes: 20},
  { id: 5, conference_id: 2, time_minutes: 25},
  { id: 6, conference_id: 2, time_minutes: 30},
  { id: 7, conference_id: 2, time_minutes: 35},
  { id: 8, conference_id: 2, time_minutes: 40}
)


# Import CNDT2020 Dummy
csv = CSV.read(File.join(Rails.root, 'db/csv/cndt2020/talks.csv'), headers: true)
Talk.seed(csv.map(&:to_hash))

csv = CSV.read(File.join(Rails.root, 'db/csv/cndt2020/speakers.csv'), headers: true)
Speaker.seed(csv.map(&:to_hash))

csv = CSV.read(File.join(Rails.root, 'db/csv/cndt2020/talks_speakers.csv'), headers: true)
csv.each do |row|
  TalksSpeaker.seed(:talk_id, :speaker_id) do |t|
    h = row.to_hash
    t.talk_id = h["talk_id"]
    t.speaker_id = h["speaker_id"]
  end
end

# Import CNDO2021 Dummy
csv = CSV.read(File.join(Rails.root, 'db/csv/cndo2021/talks.csv'), headers: true)
Talk.seed(csv.map(&:to_hash))

csv = CSV.read(File.join(Rails.root, 'db/csv/cndo2021/speakers.csv'), headers: true)
Speaker.seed(csv.map(&:to_hash))

csv = CSV.read(File.join(Rails.root, 'db/csv/cndo2021/talks_speakers.csv'), headers: true)
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

Sponsor.seed(
  {
    id: 1,
    name: "日本アイ・ビー・エム株式会社",
    abbr: "ibm",
    conference_id: 1,
    url: "https://www.ibm.com/jp-ja/cloud/cloud-native"
  },
  {
    id: 2,
    name: "レッドハット株式会社",
    abbr: "redhat",
    conference_id: 1,
    url: "https://www.redhat.com/ja/global/japan#links"
  },
  {
    id: 3,
    name: "JFrog Japan株式会社",
    abbr: "jfrog",
    conference_id: 1,
    url: "https://jfrog.co.jp/"
  },
  {
    id: 4,
    name: "New Relic株式会社",
    abbr: "newrelic",
    conference_id: 1,
    url: "https://newrelic.co.jp/"
  },
  {
    id: 5,
    name: "CircleCI合同会社",
    abbr: "circleci",
    conference_id: 1,
    url: "https://circleci.com/ja/"
  },
  {
    id: 6,
    name: "F5ネットワークスジャパン合同会社",
    abbr: "nginx",
    conference_id: 1,
    url: "https://www.nginx.co.jp/"
  },
  {
    id: 7,
    name: "日本オラクル株式会社",
    abbr: "Oracle",
    conference_id: 1,
    url: "https://www.oracle.com/jp/index.html"
  },
  {
    id: 8,
    name: "日本マイクロソフト株式会社/Microsoft Corporation",
    abbr: "microsoft",
    conference_id: 1,
    url: "https://news.microsoft.com/ja-jp/"
  },
  {
    id: 9,
    name: "株式会社サイバーエージェント",
    abbr: "cyberagent",
    conference_id: 1,
    url: "https://developers.cyberagent.co.jp/"
  },
  {
    id: 10,
    name: "富士通株式会社",
    abbr: "fujitsu",
    conference_id: 1,
    url: "https://www.fujitsu.com/jp/"
  },
  {
    id: 11,
    name: "サイオステクノロジー株式会社",
    abbr: "sios",
    conference_id: 1,
    url: "https://sios.jp/"
  },
  {
    id: 12,
    name: "株式会社エヌ・ティ・ティ・データ",
    abbr: "nttdata",
    conference_id: 1,
    url: "https://www.nttdata.com/jp/ja/"
  },
  {
    id: 13,
    name: "株式会社カサレアル",
    abbr: "casareal",
    conference_id: 1,
    url: "https://www.casareal.co.jp/"
  },
  {
    id: 14,
    name: "株式会社はてな",
    abbr: "hatena",
    conference_id: 1,
    url: "https://mackerel.io"
  },
  {
    id: 15,
    name: "Sysdig Japan合同会社",
    abbr: "sysdig",
    conference_id: 1,
    url: "https://sysdig.jp"
  },
  {
    id: 16,
    name: "Canonical/Ubuntu",
    abbr: "canonical",
    conference_id: 1,
    url: "https://jp.ubuntu.com/"
  },
  {
    id: 17,
    name: "GMOペパボ株式会社",
    abbr: "pepabo",
    conference_id: 1,
    url: "https://pepabo.com/"
  },
  {
    id: 18,
    name: "株式会社ディバータ",
    abbr: "kuroco",
    conference_id: 1,
    url: "https://kuroco.app/"
  },
  {
    id: 19,
    name: "グーグル・クラウド・ジャパン合同会社",
    abbr: "google",
    conference_id: 1,
    url: 'https://cloud.google.com/anthos'
  },
  {
    id: 20,
    name: '株式会社LegalForce',
    abbr: 'legalforce',
    conference_id: 1,
    url: 'https://www.legalforce.co.jp/'
  },
  {
    id: 21,
    name: 'SUSE ソフトウエア ソリューションズ ジャパン株式会社',
    abbr: 'suse',
    conference_id: 1,
    url: 'https://www.suse.com/ja-jp/solutions/devops/'
  },
  {
    id: 22,
    name: 'ヴイエムウェア株式会社',
    abbr: 'vmware',
    conference_id: 1,
    url: 'https://www.vmware.com/jp.html'
  },
  {
    id: 23,
    name: 'ミランティス・ジャパン株式会社',
    abbr: 'mirantis',
    conference_id: 1,
    url: 'https://www.mirantis.co.jp/'
  },
  {
    id: 24,
    name: 'Elastic',
    abbr: 'elastic',
    conference_id: 1,
    url: 'https://www.elastic.co'
  },
  {
    id: 25,
    name: 'Plaid',
    abbr: 'Plaid',
    conference_id: 1,
    url: 'https://plaid.co.jp/'
  },
  {
    id: 26,
    name: '日本電気株式会社',
    abbr: 'nec',
    conference_id: 1,
    url: 'https://jpn.nec.com/'
  },
  {
    id: 27,
    name: 'Rancher Labs, Inc.',
    abbr: 'rancherlabs',
    conference_id: 1,
    url: 'https://www.rancher.co.jp/'
  },
  {
    id: 28,
    name: 'Linux Foundation',
    abbr: 'lf',
    conference_id: 1,
    url: 'https://www.cncf.io/'
  },
  {
    id: 30,
    name: 'CircleCI合同会社',
    abbr: 'circleci',
    conference_id: 2,
    url: 'https://circleci.com/ja/'
  },
  {
    id: 31,
    name: 'New Relic株式会社',
    abbr: 'newrelic',
    conference_id: 2,
    url: 'https://newrelic.com/jp'
  },
  {
    id: 32,
    name: 'JFrog Japan株式会社',
    abbr: 'jfrog',
    conference_id: 2,
    url: 'https://jfrog.com/ja/'
  },
  {
    id: 33,
    name: 'Datadog Japan 合同会社',
    abbr: 'datadog',
    conference_id: 2,
    url: 'https://www.datadoghq.com/ja'
  },
  {
    id: 34,
    name: 'レッドハット株式会社',
    abbr: 'redhat',
    conference_id: 2,
    url: 'https://www.redhat.com/en/global/japan'
  },
  {
    id: 35,
    name: 'GMOインターネットグループ',
    abbr: 'gmo',
    conference_id: 2,
    url: 'https://www.gmo.jp/'
  },
  {
    id: 36,
    name: 'SUSE ソフトウエア ソリューションズ ジャパン株式会社',
    abbr: 'suse',
    conference_id: 2,
    url: 'https://www.suse.com/ja-jp/ '
  },
  {
    id: 37,
    name: 'アクイアジャパン合同会社',
    abbr: 'acquia',
    conference_id: 2,
    url: 'https://www.acquia.com/jp'
  },
  {
    id: 38,
    name: 'ヴイエムウェア株式会社',
    abbr: 'vmware',
    conference_id: 2,
    url: 'https://www.vmware.com/jp'
  },
  {
    id: 39,
    name: '日本マイクロソフト株式会社',
    abbr: 'microsoft',
    conference_id: 2,
    url: 'https://azure.microsoft.com/ja-jp/developer/'
  },
  {
    id: 40,
    name: 'F5ネットワークスジャパン合同会社／NGINX',
    abbr: 'nginx',
    conference_id: 2,
    url: 'https://www.nginx.co.jp/'
  },
  {
    id: 41,
    name: 'SCSK株式会社',
    abbr: 'scsk',
    conference_id: 2,
    url: 'https://www.scsk.jp/sp/sysdig/'
  },
  {
    id: 42,
    name: 'LINE株式会社',
    abbr: 'line',
    conference_id: 2,
    url: 'https://engineering.linecorp.com/ja/'
  },
  {
    id: 43,
    name: '株式会社LegalForce',
    abbr: 'legalforce',
    conference_id: 2,
    url: 'https://www.legalforce.co.jp/'
  },
  {
    id: 44,
    name: 'ミランティス・ジャパン株式会社',
    abbr: 'mirantis',
    conference_id: 2,
    url: 'https://www.mirantis.co.jp/lens/'
  },
  {
    id: 45,
    name: 'Plaid',
    abbr: 'plaid',
    conference_id: 2,
    url: 'https://plaid.co.jp/'
  },
  {
    id: 46,
    name: '株式会社クラウドネイティブ',
    abbr: 'cloudnative',
    conference_id: 2,
    url: 'https://cloudnative.co.jp/'
  },
  {
    id: 47,
    name: 'The Linux Foundation',
    abbr: 'lf',
    conference_id: 2,
    url: 'https://www.linuxfoundation.jp/'
  },
  {
    id: 48,
    name: 'LPI-Japan',
    abbr: 'lpi',
    conference_id: 2,
    url: 'https://lpi.or.jp/'
  },
  {
    id: 49,
    name: 'FooBar',
    abbr: 'foobar',
    conference_id: 3,
    url: 'https://repl.info/'
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
    name: "Gold",
    order: 4,
  },
  { id: 4,
    conference_id: 1,
    name: "Mini Session",
    order: 6,
  },
  { id: 5,
    conference_id: 1,
    name: "Booth",
    order: 5,
  },
  { id: 6,
    conference_id: 1,
    name: "CM",
    order: 7,
  },
  { id: 7,
    conference_id: 1,
    name: "Tool",
    order: 8,
  },
  { id: 8,
    conference_id: 1,
    name: "Special Collaboration",
    order: 1,
  },
  { id: 10,
    conference_id: 2,
    name: "Diamond",
    order: 1,
  },
  { id: 11,
    conference_id: 2,
    name: "Platinum",
    order: 2,
  },
  { id: 12,
    conference_id: 2,
    name: "Gold",
    order: 3,
  },
  { id: 13,
    conference_id: 2,
    name: "Booth",
    order: 4,
  },
  { id: 14,
    conference_id: 2,
    name: "CM",
    order: 5,
  },
  { id: 15,
    conference_id: 2,
    name: "Tool",
    order: 6,
  },
  { id: 16,
    conference_id: 2,
    name: "Logo",
    order: 7,
  },
  { id: 17,
    conference_id: 3,
    name: "Diamond",
    order: 1,
  }
)

[
  [1, 'Diamond', 'ibm', 1],
  [2, 'Diamond', 'redhat', 1],
  [3, 'Diamond', 'jfrog', 1],
  [4, 'Diamond', 'NewRelic', 1],
  [5, 'Platinum', 'circleci', 1],
  [6, 'Platinum', 'nginx', 1],
  [7, 'Platinum', 'oracle', 1],
  [8, 'Platinum', 'microsoft', 1],
  [9, 'Platinum', 'google', 1],
  [10, 'Platinum', 'legalforce', 1],
  [11, 'Platinum', 'suse', 1],
  [12, 'Platinum', 'vmware', 1],
  [13, 'Gold', 'cyberagent', 1],
  [14, 'Gold', 'fujitsu', 1],
  [15, 'Gold', 'sios', 1],
  [16, 'Gold', 'nttdata', 1],
  [17, 'Gold', 'casareal', 1],
  [18, 'Gold', 'hatena', 1],
  [19, 'Gold', 'sysdig', 1],
  [20, 'Booth', 'canonical', 1],
  [21, 'Booth', 'circleci', 1],
  [22, 'Booth', 'nginx', 1],
  [23, 'Booth', 'ibm', 1],
  [24, 'Booth', 'pepabo', 1],
  [25, 'Booth', 'legalforce', 1],
  [26, 'Mini Session', 'ibm', 1],
  [27, 'CM', 'canonical', 1],
  [28, 'CM', 'ibm', 1],
  [29, 'CM', 'kuroco', 1],
  [30, 'CM', 'fujitsu', 1],
  [31, 'CM', 'legalforce', 1],
  [32, 'Gold', 'mirantis', 1],
  [33, 'Booth', 'Elastic', 1],
  [34, 'Tool', 'Plaid', 1],
  [35, 'Gold', 'nec', 1],
  [36, 'Platinum', 'rancherlabs', 1],
  [37, 'Booth', 'rancherlabs', 1],
  [38, 'Special Collaboration', 'lf', 1],
  [39, 'Booth', 'redhat', 1],
  [40, 'Diamond', 'circleci', 2],
  [41, 'Diamond', 'newrelic', 2],
  [42, 'Diamond', 'jfrog', 2],
  [43, 'Diamond', 'datadog', 2],
  [44, 'Diamond', 'redhat', 2],
  [45, 'Diamond', 'gmo', 2],
  [46, 'Platinum', 'suse', 2],
  [47, 'Platinum', 'acquia', 2],
  [48, 'Platinum', 'vmware', 2],
  [49, 'Platinum', 'microsoft', 2],
  [50, 'Platinum', 'nginx', 2],
  [51, 'Gold', 'scsk', 2],
  [52, 'Gold', 'line', 2],
  [53, 'Booth', 'circleci', 2],
  [55, 'Booth', 'jfrog', 2],
  [56, 'Booth', 'datadog', 2],
  [57, 'Booth', 'redhat', 2],
  [59, 'Booth', 'nginx', 2],
  [60, 'CM', 'legalforce', 2],
  [61, 'CM', 'mirantis', 2],
  [62, 'CM', 'gmo', 2],
  [63, 'CM', 'line', 2],
  [64, 'Tool', 'plaid', 2],
  [65, 'Platinum', 'cloudnative', 2],
  [58, 'Logo', 'lf', 2],
  [66, 'Logo', 'lpi', 2],
  [67, 'Diamond', 'foobar', 3],
].each do |sponsors_sponsor_type|
  id = sponsors_sponsor_type[0]
  sponsor_type = SponsorType.find_by(name: sponsors_sponsor_type[1], conference_id: sponsors_sponsor_type[3])
  sponsor = Sponsor.find_by(abbr: sponsors_sponsor_type[2], conference_id: sponsors_sponsor_type[3])
  SponsorsSponsorType.seed({id: id, sponsor_type_id: sponsor_type.id, sponsor_id: sponsor.id})
  if sponsors_sponsor_type[1] == 'Booth'
    Booth.seed(:conference_id, :sponsor_id) do |s|
      s.conference_id = sponsors_sponsor_type[3]
      s.sponsor_id = sponsor.id
    end
  end
end

[
  [1, 'canonical', 'sponsors/cndt2020/canonical.png', 1],
  [2, 'casareal', 'sponsors/cndt2020/casareal.png', 1],
  [3, 'circleci', 'sponsors/cndt2020/circleci.png', 1],
  [4, 'cyberagent', 'sponsors/cndt2020/cyberagent.png', 1],
  [5, 'kuroco', 'sponsors/cndt2020/diverta.png', 1],
  [6, 'nginx', 'sponsors/cndt2020/f5.jpg', 1],
  [7, 'fujitsu', 'sponsors/cndt2020/fujitsu.png', 1],
  [8, 'pepabo', 'sponsors/cndt2020/gmo-pepabo.png', 1],
  [9, 'google', 'sponsors/cndt2020/google.png', 1],
  [10, 'hatena', 'sponsors/cndt2020/hatena.png', 1],
  [11, 'ibm', 'sponsors/cndt2020/ibm.jpg', 1],
  [12, 'jfrog', 'sponsors/cndt2020/jfrog.png', 1],
  [13, 'legalforce', 'sponsors/cndt2020/legalforce.png', 1],
  [14, 'microsoft', 'sponsors/cndt2020/microsoft.png', 1],
  [15, 'nttdata', 'sponsors/cndt2020/nttdata.png', 1],
  [16, 'oracle', 'sponsors/cndt2020/oracle.png', 1],
  [17, 'rancherlabs', 'sponsors/cndt2020/rancherlabs.png', 1],
  [18, 'redhat', 'sponsors/cndt2020/redhat.png', 1],
  [19, 'sios', 'sponsors/cndt2020/sios.png', 1],
  [20, 'sysdig', 'sponsors/cndt2020/sysdig.png', 1],
  [21, 'NewRelic', 'sponsors/cndt2020/newrelic.png', 1],
  [22, 'suse', 'sponsors/cndt2020/suse.png', 1],
  [23, 'vmware', 'sponsors/cndt2020/vmware.png', 1],
  [24, 'mirantis', 'sponsors/cndt2020/mirantis.png', 1],
  [25, 'Elastic', 'sponsors/cndt2020/elastic.png', 1],
  [26, 'Plaid', 'sponsors/cndt2020/plaid.png', 1],
  [27, 'nec', 'sponsors/cndt2020/nec.png', 1],
  [28, 'lf', 'sponsors/cndt2020/cncf.jpg', 1],
  [30, 'circleci', 'sponsors/cndo2021/circleci.png', 2],
  [31, 'newrelic', 'sponsors/cndo2021/newrelic.png', 2],
  [32, 'jfrog', 'sponsors/cndo2021/jfrog.png', 2],
  [33, 'datadog', 'sponsors/cndo2021/datadog.png', 2],
  [34, 'redhat', 'sponsors/cndo2021/redhat.png', 2],
  [35, 'gmo', 'sponsors/cndo2021/gmo.png', 2],
  [36, 'suse', 'sponsors/cndo2021/suse.png', 2],
  [37, 'acquia', 'sponsors/cndo2021/acquia.png', 2],
  [38, 'vmware', 'sponsors/cndo2021/vmware.png', 2],
  [39, 'microsoft', 'sponsors/cndo2021/microsoft.png', 2],
  [40, 'nginx', 'sponsors/cndo2021/nginx.png', 2],
  [41, 'scsk', 'sponsors/cndo2021/scsk.png', 2],
  [42, 'line', 'sponsors/cndo2021/line.png', 2],
  [43, 'legalforce', 'sponsors/cndo2021/legalforce.png', 2],
  [44, 'mirantis', 'sponsors/cndo2021/mirantis.png', 2],
  [45, 'plaid', 'sponsors/cndo2021/plaid.png', 2],
  [46, 'cloudnative', 'sponsors/cndo2021/cloudnative.png', 2],
  [47, 'lf', 'sponsors/cndo2021/lf.png', 2],
  [48, 'lpi', 'sponsors/cndo2021/lpi.png', 2],
].each do |logo|
  SponsorAttachment.seed(
    { id: logo[0],
      sponsor_id: Sponsor.find_by(abbr: logo[1], conference_id: logo[3]).id,
      type: 'SponsorAttachmentLogoImage',
      url: logo[2]
    }
  )
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

ChatMessage.seed(
  {id: 1, body: "talk1: chat message 1", conference_id: 2, room_id: 101, room_type: 'talk', message_type: 0},
  {id: 2, body: "talk1: chat message 2", conference_id: 2, room_id: 101, room_type: 'talk', message_type: 0},
  {id: 3, body: "talk1: chat message 3", conference_id: 2, room_id: 101, room_type: 'talk', message_type: 1},
  {id: 4, body: "talk6: chat message 3", conference_id: 2, room_id: 105, room_type: 'talk', message_type: 0},
  {id: 5, body: "talk6: chat message 3", conference_id: 2, room_id: 105, room_type: 'talk', message_type: 1},
)

Announcement.seed(
  {id: 1, conference_id: 1, publish_time: "2020-08-24 10:00:00", publish: true, body: <<'EOS'
9/2（水）19:00-20:30に、プレイベントとして、CNDT2020 Rejektsを開催します！CNDT2020にお申込の方はどなたでもご参加できます！ぜひご視聴ください！,
EOS
  },
  {id: 2, conference_id: 1, publish_time: "2020-08-20 10:00:00", publish: true, body: <<'EOS'
最終セッションの実施時間を18:00-18:40に変更致しました。それに伴い、イベントの終了時間は19:00となります(ask the speaker含む）
<a href="https://event.cloudnativedays.jp/cndt2020/talks/66" target="_blank">「Cloud Foundry on K8sでクラウドネイティブ始めませんか？」（有元 久住 / SUSE )</a>のセッション時間が、9/9 16:00-16:40に変更になりました。予定が重複する場合は、登録セッションを変更してください
EOS
}
)

ProposalItemConfig.seed(
  {
    id: 1,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'expected_participant',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'architect - システム設計'
  },
  {
    id: 2,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'expected_participant',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'developer - システム開発'
  },
  {
    id: 3,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'expected_participant',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'app-developer - アプリケーション開発'
  },
  {
    id: 4,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'expected_participant',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'operator/sys-admin - 運用管理/システム管理'
  },
  {
    id: 5,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'expected_participant',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'CxO/biz - ビジネス層'
  },
  {
    id: 6,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'expected_participant',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'その他'
  },
  {
    id: 7,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'Dev/QA（開発環境）'
  },
  {
    id: 8,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'PoC（検証）'
  },
  {
    id: 9,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'Production（本番環境）'
  },
)
