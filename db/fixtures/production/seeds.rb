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
    name: "CloudNative Days Online 2021",
    abbr: "cndo2021",
    status: 0, # registered
    theme: "+Native 〜ともに創るクラウドネイティブの世界〜",
    copyright: '© CloudNative Days Online 2021 (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cndo2021.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy__for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    about: <<'EOS'
CloudNative Days はコミュニティ、企業、技術者が一堂に会し、クラウドネイティブムーブメントを牽引することを目的としたテックカンファレンスです。
最新の活用事例や先進的なアーキテクチャを学べるのはもちろん、ナレッジの共有やディスカッションの場を通じて登壇者と参加者、参加者同士の繋がりを深め、初心者から熟練者までが共に成長できる機会を提供します。
皆様がクラウドネイティブ技術を適切に選択し、活用し、次のステップに進む手助けになることを願っています。
クラウドネイティブで、未来を共に創造しましょう。
EOS
  }
)

ConferenceDay.seed(
  {id: 1, date: "2020-09-08", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: false},
  {id: 2, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: false},
  {id: 3, date: "2020-09-02", start_time: "19:00", end_time: "21:00", conference_id: 1, internal: true}, #rejekts
  {id: 4, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: true}, #CM
  {id: 5, date: "2020-09-09", start_time: "12:00", end_time: "20:00", conference_id: 1, internal: true}, #Mini session

  {id: 6, date: "2021-03-11", start_time: "12:00", end_time: "20:00", conference_id: 2, internal: false},
  {id: 7, date: "2021-03-12", start_time: "12:00", end_time: "20:00", conference_id: 2, internal: false},
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
  { id: 4, conference_id: 1, name: "日本マイクロソフト株式会社への個人情報提供に同意する"}
)

Track.seed(
  { id: 1, number: 1, name: "A", conference_id: 1},
  { id: 2, number: 2, name: "B", conference_id: 1},
  { id: 3, number: 3, name: "C", conference_id: 1},
  { id: 4, number: 4, name: "D", conference_id: 1},
  { id: 5, number: 5, name: "E", conference_id: 1},
  { id: 6, number: 6, name: "F", conference_id: 1}
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
  { id: 18, conference_id: 1, name: "Keynote"}
)

TalkDifficulty.seed(
  { id: 1, conference_id: 1, name: "初級者"},
  { id: 2, conference_id: 1, name: "中級者"},
  { id: 3, conference_id: 1, name: "上級者"},
  { id: 4, conference_id: 1, name: ""},
)

if ENV['REVIEW_APP'] == 'true'
  csv = CSV.read(File.join(Rails.root, 'db/talks.csv'), headers: true)
  Talk.seed(csv.map(&:to_hash))

  csv = CSV.read(File.join(Rails.root, 'db/speakers.csv'), headers: true)
  Speaker.seed(csv.map(&:to_hash))

  TalksSpeaker.delete_all
  csv = CSV.read(File.join(Rails.root, 'db/talks_speakers.csv'), headers: true)
  TalksSpeaker.seed(csv.map(&:to_hash))
  
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
end

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
  }
)

[
  [1, 'Diamond', 'ibm'],
  [2, 'Diamond', 'redhat'],
  [3, 'Diamond', 'jfrog'],
  [4, 'Diamond', 'NewRelic'],
  [5, 'Platinum', 'circleci'],
  [6, 'Platinum', 'nginx'],
  [7, 'Platinum', 'oracle'],
  [8, 'Platinum', 'microsoft'],
  [9, 'Platinum', 'google'],
  [10, 'Platinum', 'legalforce'],
  [11, 'Platinum', 'suse'],
  [12, 'Platinum', 'vmware'],
  [13, 'Gold', 'cyberagent'],
  [14, 'Gold', 'fujitsu'],
  [15, 'Gold', 'sios'],
  [16, 'Gold', 'nttdata'],
  [17, 'Gold', 'casareal'],
  [18, 'Gold', 'hatena'],
  [19, 'Gold', 'sysdig'],
  [20, 'Booth', 'canonical'],
  [21, 'Booth', 'circleci'],
  [22, 'Booth', 'nginx'],
  [23, 'Booth', 'ibm'],
  [24, 'Booth', 'pepabo'],
  [25, 'Booth', 'legalforce'],
  [26, 'Mini Session', 'ibm'],
  [27, 'CM', 'canonical'],
  [28, 'CM', 'ibm'],
  [29, 'CM', 'kuroco'],
  [30, 'CM', 'fujitsu'],
  [31, 'CM', 'legalforce'],
  [32, 'Gold', 'mirantis'],
  [33, 'Booth', 'Elastic'],
  [34, 'Tool', 'Plaid'],
  [35, 'Gold', 'nec'],
  [36, 'Platinum', 'rancherlabs'],
  [37, 'Booth', 'rancherlabs'],
  [38, 'Special Collaboration', 'lf'],
  [39, 'Booth', 'redhat'],
].each do |sponsors_sponsor_type|
  id = sponsors_sponsor_type[0]
  sponsor_type = SponsorType.find_by(name: sponsors_sponsor_type[1])
  sponsor = Sponsor.find_by(abbr: sponsors_sponsor_type[2])
  SponsorsSponsorType.seed({id: id, sponsor_type_id: sponsor_type.id, sponsor_id: sponsor.id})
  if sponsors_sponsor_type[1] == 'Booth'
    Booth.seed(:conference_id, :sponsor_id) do |s|
      s.conference_id = 1
      s.sponsor_id = sponsor.id
      s.published = false
    end
  end
end

[
  [1, 'canonical', 'sponsors/canonical.png'],
  [2, 'casareal', 'sponsors/casareal.png'],
  [3, 'circleci', 'sponsors/circleci.png'],
  [4, 'cyberagent', 'sponsors/cyberagent.png'],
  [5, 'kuroco', 'sponsors/diverta.png'],
  [6, 'nginx', 'sponsors/f5.jpg'],
  [7, 'fujitsu', 'sponsors/fujitsu.png'],
  [8, 'pepabo', 'sponsors/gmo-pepabo.png'],
  [9, 'google', 'sponsors/google.png'],
  [10, 'hatena', 'sponsors/hatena.png'],
  [11, 'ibm', 'sponsors/ibm.jpg'],
  [12, 'jfrog', 'sponsors/jfrog.png'],
  [13, 'legalforce', 'sponsors/legalforce.png'],
  [14, 'microsoft', 'sponsors/microsoft.png'],
  [15, 'nttdata', 'sponsors/nttdata.png'],
  [16, 'oracle', 'sponsors/oracle.png'],
  [17, 'rancherlabs', 'sponsors/rancherlabs.png'],
  [18, 'redhat', 'sponsors/redhat.png'],
  [19, 'sios', 'sponsors/sios.png'],
  [20, 'sysdig', 'sponsors/sysdig.png'],
  [21, 'NewRelic', 'sponsors/newrelic.png'],
  [22, 'suse', 'sponsors/suse.png'],
  [23, 'vmware', 'sponsors/vmware.png'],
  [24, 'mirantis', 'sponsors/mirantis.png'],
  [25, 'Elastic', 'sponsors/elastic.png'],
  [26, 'Plaid', 'sponsors/plaid.png'],
  [27, 'nec', 'sponsors/nec.png'],
  [28, 'lf', 'sponsors/cncf.jpg'],
].each do |logo|
  SponsorAttachment.seed(
    { id: logo[0],
      sponsor_id: Sponsor.find_by(abbr: logo[1]).id,
      type: 'SponsorAttachmentLogoImage',
      url: logo[2]
    }
  )
end
