
DUMMY_TEXT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

Conference.seed(
  {
    id: 1,
    name: "CloudNative Days Tokyo 2020",
    abbr: "cndt2020",
    conference_status: "closed",
    speaker_entry: 0,
    attendee_entry: 0,
    theme: "+Native 〜ともに創るクラウドネイティブの世界〜",
    copyright: '© CloudNative Days Tokyo 2020 (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Tokyo 2020 Committee",
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
    conference_status: "archived",
    speaker_entry: 1, # enabled
    attendee_entry: 0, # disabled
    theme: "ともに踏み出す CloudNative祭",
    copyright: '© CloudNative Days Spring 2021 ONLINE (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cndo2021.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Spring 2021 ONLINE Committee",
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
    conference_status: "closed",
    speaker_entry: 1,
    attendee_entry: 0,
    theme: "Continuous 〜 技術を知り、試し、取り入れる 〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cicd2021.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CI/CD Conference 2021 Committee",
    about: <<'EOS'
CI/CD Conferenceは、CI/CDに特化したテックカンファレンスです。『技術を知り、試して、取り入れる』のコンセプトのもと、参加者が優れたCI/CDの知見を取り入れ、改善を行っていけるイベントを目指しています。そして、ゆくゆくは参加者が登壇者となり、他の人に知見を共有していける、Continuousなイベントでありたいと思っています。
EOS
  },
  {
    id: 4,
    name: "CloudNative Days Tokyo 2021",
    abbr: "cndt2021",
    conference_status: "closed",
    theme: "＋Native 〜ともに繋げるクラウドネイティブの世界〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cndt2021.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Tokyo 2021 Committee",
    about: <<'EOS'
    "CloudNative Days" は最新の活用事例や先進的なアーキテクチャを学べるのはもちろん、ナレッジの共有やディスカッションの場を通じて登壇者と参加者、参加者同士の繋がりを深め、初心者から熟練者までが共に成長できる機会を提供するテックカンファレンスです。
    今日、多くの技術者、コミュニティ、企業がクラウドネイティブを目指す旅路を歩んでいます。

    それぞれの旅路において、拾い集めた様々な経験、知識、疑問、悩みを共有する"交差点"にして欲しい、そんな思いが"CloudNative Days" には込められています。
    まだ旅への一歩を踏み出せていない人も、再び旅に出る人も、この"交差点"に集まることで過去を振り返りながら新たなクラウドネイティブの旅をともに歩み進めることができると私達は信じています。

    旅をする準備をしませんか？ "交差点"で会えるのを楽しみにしています。
EOS
  },
  {
    id: 5,
    name: "Observability Conference 2022 by CloudNative Days",
    abbr: "o11y2022",
    conference_status: "closed",
    theme: "Observe the Observability 〜知らないことを知り、見えていないものを見る〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_o11y2022.md')), #TODO: o11y2022版プライバシーポリシー
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndo2021.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "Observability Conference 2022 Committee",
    about: <<'EOS'
    Observability Conference（O11yCon）は、オブザーバビリティ（可観測性）に特化したテックカンファレンスです。

    どのようなツールがあるのか・実業務での活用事例、そしてそもそも オブザーバビリティとは何なのか。

    それぞれの情報を共有し、オブザーバビリティに対する理解を深め合いましょう。そうして得られた知見を、今度は皆さん自身のシステム/アプリケーションに活かすことで、より実体や現状が高い解像度ではっきりと見えてくるはずです。

    まさに、知らなかったことを知ることで、見えていないものが見えるようになります。

    さまざまなロールの垣根を超えて、ともにオブザーバビリティの道を明らかにしていきましょう。
EOS
  },
  {
    id: 6,
    name: "CloudNative Security Conference 2022 by CloudNative Days",
    abbr: "cnsec2022",
    theme: "Go \"Green\"〜ともに目指す持続可能なセキュリティ〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cnsec2022.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Security Conference 2022 Committee",
    about: <<'EOS'
CloudNative Security Conference 2022 (CNSec2022) は、クラウドネイティブセキュリティに特化したテックカンファレンスです。

クラウドネイティブなセキュリティとは、いったいどのようなものでしょうか。私達は、"Green"というキーワードに想いを込めてみました。

自然と同じく、セキュリティはシステムやアプリケーション、サービスなどにおいて欠くことのできない大切なものです。しかし、手放しにしていてはやがてシステムは衰退していくことになるでしょう。

刻一刻と変化する状況の中で、新しい知見・技術を導入したり、脅威になる部分や脆弱な仕組みを伐採したりしながら、新たな自然の芽を育てるように常に最適で正常な状態に整えていかなければならないと私達は考えます。

脅威に対し、継続して柔軟かつ俊敏に対応できる、身軽でしなやかな持続可能のセキュリティこそ、クラウドネイティブ時代のセキュリティの理想のひとつではないでしょうか。

そのような持続可能なセキュリティを実現するために、このイベントで様々な知見や技術を持ち寄って、安全で豊かな"Green"をともに目指してみませんか？
EOS
  },
  {
    id: 7,
    name: "CloudNative Days Tokyo 2022",
    abbr: "cndt2022",
    theme: "+Native 〜ともに広がるクラウドネイティブの世界〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    privacy_policy: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_cndt2022.md')),
    privacy_policy_for_speaker: File.read(File.join(Rails.root, 'db/fixtures/production/privacy_policy_for_speaker_cndt2022.md')),
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Tokyo 2022 Committee",
    about: <<'EOS'
    "CloudNative Days" は最新の活用事例や先進的なアーキテクチャを学べるのはもちろん、ナレッジの共有やディスカッションの場を通じて登壇者と参加者、参加者同士の繋がりを深め、初心者から熟練者までが共に成長できる機会を提供するテックカンファレンスです。

    世の中の在り方が広がっても、私たちは共に物理的・時間的な距離を乗り越えていきます。
    クラウドネイティブの世界が広がっても、私たちは共に新しい未知の道を開拓し続けていきます。

    これまでもこれからも、広がり続けるクラウドネイティブにおいて、様々な人・会社・技術・考え方で目指す多様性を受け入れ、共に時間を共有し、新しい地図を広げていきましょう。
EOS
  },
  {
    id: 8,
    name: "CI/CD Conference 2023 by CloudNative Days",
    abbr: "cicd2023",
    theme: "Continuous 〜ともに回す高速なアプリケーション開発ライフサイクル〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CI/CD Conference 2023 Committee",
    about: <<'EOS'
    CI/CD Conference 2023 by CloudNative Days（CICD2023）は、CI/CDに特化したテックカンファレンスです。

    1st SprintであるCI/CD Conference 2021での『技術を知り、試して、取り入れる』から、2nd Sprintである今回はより具体的に『ともに回す高速なアプリケーション開発ライフサイクル』をコンセプトとして掲げました。

    クラウドネイティブにアプリケーション開発のライフサイクルを回すことによって、設計、開発、テスト、デプロイ、運用、フィードバックのサイクルを高速化できます。

    このカンファレンスでは、それぞれのフェーズでの知見を交流させて新たな気づきを得ることで、次のSprintでの更なる改善・進化の実現を目的とします。

    開発と運用の垣根を超えて、継続的に価値を高めるライフサイクルをともに回していける世界を一緒に体験してみましょう！
EOS
  },
  {
    id: 9,
    name: "CloudNative Days Fukuoka 2023",
    abbr: "cndf2023",
    theme: "“Unlearning” 〜 クラウドの『べき』を外して、新たな世界と繋がろう",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Committee",
    about: <<'EOS'
      業務でクラウドを利用していても、その真のパワーを活用できていないと感じている人は多いのではないでしょうか？
      一方で、高度なクラウド技術を持っているのに、自信が持てなかったり、自らの真価に気づいていない組織も多いのではないでしょうか。
      そこで、いったん「クラウドネイティブとはかくあるべき」という固定概念を外して、気軽にクラウド技術について語り合いませんか？
      クラウドやコンテナを使い倒したいインフラエンジニア、クラウドの可能性をもっと引き出したいアプリエンジニアが、知見や課題を共有しながら、新たな人や技術と繋がる場所を作りたいと考えています。

　    そこで、CloudNative Days Japan Tour復活の第一弾として、先進IT・スタートアップコミュニティを擁する福岡の地でCNDF2023を開催します。福岡発で、現地だけでなくオンライン配信を通して、全国のクラウドコミュニティの活性化への貢献を目指します。
EOS
  },
  {
    id: 10,
    name: "Test Event Winter 2020",
    conference_status: "archived",
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

  {id: 11, date: "2021-11-04", start_time: "12:00", end_time: "19:20", conference_id: 4, internal: false},
  {id: 12, date: "2021-11-05", start_time: "12:00", end_time: "19:20", conference_id: 4, internal: false},
  {id: 13, date: "2021-10-18", start_time: "19:00", end_time: "21:00", conference_id: 4, internal: true}, #Pre event

  {id: 14, date: "2022-03-11", start_time: "12:00", end_time: "19:00", conference_id: 5, internal: false},
  {id: 15, date: "2022-02-16", start_time: "19:00", end_time: "21:00", conference_id: 5, internal: true}, #Pre event

  # CNSEC2022
  {id: 16, date: "2022-08-05", start_time: "13:00", end_time: "19:00", conference_id: 6, internal: false},
  {id: 17, date: "2022-07-15", start_time: "19:00", end_time: "21:00", conference_id: 6, internal: true}, #Pre event

  # CNDT2022
  {id: 18, date: "2022-11-21", start_time: "9:50", end_time: "18:00", conference_id: 7, internal: false},
  {id: 19, date: "2022-11-22", start_time: "9:50", end_time: "18:00", conference_id: 7, internal: false},
  {id: 20, date: "2022-11-01", start_time: "19:00", end_time: "21:00", conference_id: 7, internal: true}, #Pre event

  # CICD2023
  {id: 21, date: "2023-03-20", start_time: "12:00", end_time: "18:00", conference_id: 8, internal: false},
  {id: 22, date: "2023-02-27", start_time: "19:00", end_time: "21:00", conference_id: 8, internal: true}, #Pre event
  {id: 23, date: "2023-03-04", start_time: "09:00", end_time: "21:00", conference_id: 8, internal: true}, #Rehearsal
  {id: 24, date: "2023-03-19", start_time: "09:00", end_time: "21:00", conference_id: 8, internal: true}, #Rehearsal2

  # CNDF2023
  {id: 25, date: "2023-08-02", start_time: "12:00", end_time: "18:00", conference_id: 9, internal: false}, # 前夜祭
  {id: 26, date: "2023-08-03", start_time: "12:00", end_time: "18:00", conference_id: 9, internal: false},
  {id: 27, date: "2023-06-22", start_time: "12:00", end_time: "18:00", conference_id: 9, internal: true},  # Reherasal
)

FormItem.seed(
  { id: 1, conference_id: 1, name: "IBMからのメールを希望する"},
  { id: 2, conference_id: 1, name: "IBMからの電話を希望する"},
  { id: 3, conference_id: 1, name: "IBMからの郵便を希望する"},
  { id: 4, conference_id: 1, name: "日本マイクロソフト株式会社への個人情報提供に同意する"},
  { id: 5, conference_id: 2, name: "日本マイクロソフト株式会社への個人情報提供に同意する"},
  { id: 6, conference_id: 7, name: "IBMからのメールを希望する"},
  { id: 7, conference_id: 7, name: "IBMからの電話を希望する"},
  { id: 8, conference_id: 7, name: "Red Hatからのメールを希望する"},
  { id: 9, conference_id: 7, name: "Red Hatからの電話を希望する"}
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
  { id: 20, number: 1, name: "A", conference_id: 4, video_platform: "vimeo", video_id: "gggggg"},
  { id: 21, number: 2, name: "B", conference_id: 4, video_platform: "vimeo", video_id: "gggggg"},
  { id: 22, number: 3, name: "C", conference_id: 4, video_platform: "vimeo", video_id: "gggggg"},
  { id: 23, number: 4, name: "D", conference_id: 4, video_platform: "vimeo", video_id: "gggggg"},
  { id: 24, number: 5, name: "E", conference_id: 4, video_platform: "vimeo", video_id: "gggggg"},
  { id: 25, number: 6, name: "F", conference_id: 4, video_platform: "vimeo", video_id: "gggggg"},
  { id: 26, number: 1, name: "A", conference_id: 5},
  { id: 27, number: 2, name: "B", conference_id: 5},
  { id: 28, number: 3, name: "C", conference_id: 5},
  { id: 29, number: 1, name: "A", conference_id: 6},
  { id: 30, number: 2, name: "B", conference_id: 6},
  { id: 31, number: 3, name: "C", conference_id: 6},

  { id: 32, number: 1, name: "A", conference_id: 7, room_id: 1},
  { id: 33, number: 2, name: "B", conference_id: 7, room_id: 2},
  { id: 34, number: 3, name: "C", conference_id: 7, room_id: 3},
  { id: 35, number: 4, name: "D", conference_id: 7, room_id: 4},
  { id: 36, number: 5, name: "E", conference_id: 7, room_id: 5},
  { id: 37, number: 6, name: "F", conference_id: 7, room_id: 6},

  { id: 38, number: 1, name: "A", conference_id: 8, room_id: 11},
  { id: 39, number: 2, name: "B", conference_id: 8, room_id: 12},
  { id: 40, number: 3, name: "C", conference_id: 8, room_id: 13},

  { id: 41, number: 1, name: "A", conference_id: 9, room_id: 11},
  { id: 42, number: 2, name: "B", conference_id: 9, room_id: 12},
  { id: 43, number: 3, name: "C", conference_id: 9, room_id: 13},
)


Room.seed(
  {id: 1,  conference_id: 7, name: 'Room1'},
  {id: 2,  conference_id: 7, name: 'レセプションルーム1'},
  {id: 3,  conference_id: 7, name: 'レセプションルーム2'},
  {id: 4,  conference_id: 7, name: 'Room6'},
  {id: 5,  conference_id: 7, name: 'Room2'},
  {id: 6,  conference_id: 7, name: 'ボードルーム'},
  {id: 7,  conference_id: 7, name: 'Room3'},
  {id: 8,  conference_id: 7, name: 'Room4'},
  {id: 9,  conference_id: 7, name: 'Room5'},
  {id: 10, conference_id: 7, name: 'Room7'},
  {id: 11, conference_id: 8, name: '8F'},
  {id: 12, conference_id: 8, name: '8D'},
  {id: 13, conference_id: 8, name: '8E'},
  {id: 14, conference_id: 9, name: 'DUMMY'},
  {id: 15, conference_id: 9, name: 'DUMMY'},
  {id: 16, conference_id: 9, name: 'DUMMY'},
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
  { id: 36, conference_id: 2, name: "Keynote"},

  { id: 37, conference_id: 4, name: "CI / CD"},
  { id: 38, conference_id: 4, name: "Customizing / Extending"},
  { id: 39, conference_id: 4, name: "IoT / Edge"},
  { id: 40, conference_id: 4, name: "Microservices / Services Mesh"},
  { id: 41, conference_id: 4, name: "ML / HPC"},
  { id: 42, conference_id: 4, name: "Networking"},
  { id: 43, conference_id: 4, name: "Operation / Monitoring / Logging"},
  { id: 44, conference_id: 4, name: "Application / Development"},
  { id: 45, conference_id: 4, name: "Runtime"},
  { id: 46, conference_id: 4, name: "Security"},
  { id: 47, conference_id: 4, name: "Serveless / FaaS"},
  { id: 48, conference_id: 4, name: "Storage / Database"},
  { id: 49, conference_id: 4, name: "Architecture Design"},
  { id: 50, conference_id: 4, name: "Hybrid Cloud / Multi Cloud"},
  { id: 51, conference_id: 4, name: "NFV / Edge"},
  { id: 52, conference_id: 4, name: "組織論"},
  { id: 53, conference_id: 4, name: "その他"},
  { id: 54, conference_id: 4, name: "Keynote"},

  { id: 55, conference_id: 7, name: "CI / CD"},
  { id: 56, conference_id: 7, name: "Customizing / Extending"},
  { id: 57, conference_id: 7, name: "IoT / Edge"},
  { id: 58, conference_id: 7, name: "Microservices / Services Mesh"},
  { id: 59, conference_id: 7, name: "ML / HPC"},
  { id: 60, conference_id: 7, name: "Networking"},
  { id: 61, conference_id: 7, name: "Operation / Monitoring / Logging"},
  { id: 62, conference_id: 7, name: "Application / Development"},
  { id: 63, conference_id: 7, name: "Runtime"},
  { id: 64, conference_id: 7, name: "Security"},
  { id: 65, conference_id: 7, name: "Serverless / FaaS"},
  { id: 66, conference_id: 7, name: "Storage / Database"},
  { id: 67, conference_id: 7, name: "Architecture Design"},
  { id: 68, conference_id: 7, name: "Hybrid Cloud / Multi Cloud"},
  { id: 69, conference_id: 7, name: "NFV / Edge"},
  { id: 70, conference_id: 7, name: "組織論"},
  { id: 71, conference_id: 7, name: "その他"},
  { id: 72, conference_id: 7, name: "Keynote"},

  { id: 73, conference_id: 9, name: "CI / CD"},
  { id: 74, conference_id: 9, name: "Customizing / Extending"},
  { id: 75, conference_id: 9, name: "IoT / Edge"},
  { id: 76, conference_id: 9, name: "Microservices / Services Mesh"},
  { id: 77, conference_id: 9, name: "ML / HPC"},
  { id: 78, conference_id: 9, name: "Networking"},
  { id: 79, conference_id: 9, name: "Operation / Monitoring / Logging"},
  { id: 80, conference_id: 9, name: "Application / Development"},
  { id: 81, conference_id: 9, name: "Runtime"},
  { id: 82, conference_id: 9, name: "Security"},
  { id: 83, conference_id: 9, name: "Serverless / FaaS"},
  { id: 84, conference_id: 9, name: "Storage / Database"},
  { id: 85, conference_id: 9, name: "Architecture Design"},
  { id: 86, conference_id: 9, name: "Hybrid Cloud / Multi Cloud"},
  { id: 87, conference_id: 9, name: "NFV / Edge"},
  { id: 88, conference_id: 9, name: "組織論"},
  { id: 89, conference_id: 9, name: "その他"},
  { id: 90, conference_id: 9, name: "Keynote"},
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
  { id: 31, conference_id: 4, name: "初級者"},
  { id: 32, conference_id: 4, name: "中級者"},
  { id: 33, conference_id: 4, name: "上級者"},
  { id: 41, conference_id: 5, name: "初級者"},
  { id: 42, conference_id: 5, name: "中級者"},
  { id: 43, conference_id: 5, name: "上級者"},
  { id: 51, conference_id: 6, name: "初級者"},
  { id: 52, conference_id: 6, name: "中級者"},
  { id: 53, conference_id: 6, name: "上級者"},
  { id: 54, conference_id: 7, name: "初級者"},
  { id: 55, conference_id: 7, name: "中級者"},
  { id: 56, conference_id: 7, name: "上級者"},
  { id: 57, conference_id: 8, name: "初級者"},
  { id: 58, conference_id: 8, name: "中級者"},
  { id: 59, conference_id: 8, name: "上級者"},
  { id: 60, conference_id: 9, name: "初級者"},
  { id: 61, conference_id: 9, name: "中級者"},
  { id: 62, conference_id: 9, name: "上級者"},
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

import_dummy_data('cndt2020', %w(talks speakers talks_speakers))
import_dummy_data('cndo2021', %w(talks speakers talks_speakers))
import_dummy_data('cicd2021', %w(talks speakers talks_speakers proposals))
import_dummy_data('cndt2021', %w(talks speakers talks_speakers proposals))
import_dummy_data('o11y2022', %w(talks speakers talks_speakers proposals))
import_dummy_data('cnsec2022', %w(talks speakers talks_speakers proposals proposal_items))
import_dummy_data('cndt2022', %w(talks speakers talks_speakers proposals proposal_items))
import_dummy_data('cicd2023', %w(talks speakers talks_speakers proposals proposal_items))

# Mock profile
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
    position: "president",
    calendar_unique_code: SecureRandom.uuid
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

# ChatMessage.seed(
#   {id: 1, body: "talk1: chat message 1", conference_id: 2, room_id: 101, room_type: 'talk', message_type: 0},
#   {id: 2, body: "talk1: chat message 2", conference_id: 2, room_id: 101, room_type: 'talk', message_type: 0},
#   {id: 3, body: "talk1: chat message 3", conference_id: 2, room_id: 101, room_type: 'talk', message_type: 1},
#   {id: 4, body: "talk6: chat message 3", conference_id: 2, room_id: 105, room_type: 'talk', message_type: 0},
#   {id: 5, body: "talk6: chat message 3", conference_id: 2, room_id: 105, room_type: 'talk', message_type: 1},
# )

Announcement.seed(
  {id: 1, conference_id: 1, publish_time: "2020-08-24 10:00:00", publish: true, body: <<'EOS'
9/2（水）19:00-20:30に、プレイベントとして、CNDT2020 Rejektsを開催します！CNDT2020にお申込の方はどなたでもご参加できます！ぜひご視聴ください！,
EOS
  },
  {id: 2, conference_id: 1, publish_time: "2020-08-20 10:00:00", publish: true, body: <<'EOS'
最終セッションの実施時間を18:00-18:40に変更致しました。それに伴い、イベントの終了時間は19:00となります(ask the speaker含む）
<a href="https://event.cloudnativedays.jp/cndt2020/talks/66" target="_blank">「Cloud Foundry on K8sでクラウドネイティブ始めませんか？」（有元 久住 / SUSE )</a>のセッション時間が、9/9 16:00-16:40に変更になりました。予定が重複する場合は、登録セッションを変更してください
EOS
},
  {id: 3, conference_id: 4, publish_time: "2021-10-11 10:00:00", publish: true, body: <<'EOS'
<a href="/cndt2021/" target="_blank">CloudNative Days Tokyo 2021</a>開催に向けて、10/18（月）19:00からプレイベントを実施します!
EOS
}
)

Ticket.seed(
  {id: "7b02e975-8418-4b40-a01d-f8011cc705e3", title: "オフライン参加", description: "aaaa", price: 0, stock: 454, conference_id: 7 },
  {id: "15ac6d96-5083-496d-9fd1-327f320a2f7b", title: "オンライン参加", description: "aaaa", price: 0, stock: 3500, conference_id: 7 },
  {id: "f4d09974-c6af-4fab-bb60-d394058e9eb8", title: "現地参加", description: "aaaa", price: 0, stock: 500, conference_id: 8 },
  {id: "5b31c315-5b70-4238-bf62-ed193480e9fd", title: "オンライン参加", description: "aaaa", price: 0, stock: 3500, conference_id: 8 },
  {id: "a7a3e5d5-0d8e-1c29-1c29-7004affe194a", title: "現地参加", description: "aaaa", price: 0, stock: 400, conference_id: 9 },
  {id: "703dc953-d3dc-5964-7c4a-815ee2498aba", title: "オンライン参加", description: "aaaa", price: 0, stock: 3500, conference_id: 9 },
)
