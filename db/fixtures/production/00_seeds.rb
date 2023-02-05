Conference.seed(
  {
    id: 1,
    name: "CloudNative Days Tokyo 2020",
    abbr: "cndt2020",
    speaker_entry: 0, # disabled
    attendee_entry: 0, # disabled
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
CloudNative Security Conference 2022 by CloudNative Days (CNSec2022) は、クラウドネイティブセキュリティに特化したテックカンファレンスです。

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
  {id: 21, date: "2023-03-20", start_time: "12:00", end_time: "19:50", conference_id: 8, internal: false},
  {id: 22, date: "2023-02-07", start_time: "19:00", end_time: "21:00", conference_id: 8, internal: true}, #Pre event
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
  { id: 10, number: 1, name: "A", conference_id: 2},
  { id: 11, number: 2, name: "B", conference_id: 2},
  { id: 12, number: 3, name: "C", conference_id: 2},
  { id: 13, number: 4, name: "D", conference_id: 2},
  { id: 14, number: 5, name: "E", conference_id: 2},
  { id: 15, number: 6, name: "F", conference_id: 2},
  { id: 16, number: 7, name: "G", conference_id: 2},
  { id: 17, number: 1, name: "A", conference_id: 3},
  { id: 18, number: 2, name: "B", conference_id: 3},
  { id: 19, number: 3, name: "C", conference_id: 3},
  { id: 20, number: 1, name: "A", conference_id: 4},
  { id: 21, number: 2, name: "B", conference_id: 4},
  { id: 22, number: 3, name: "C", conference_id: 4},
  { id: 23, number: 4, name: "D", conference_id: 4},
  { id: 24, number: 5, name: "E", conference_id: 4},
  { id: 25, number: 6, name: "F", conference_id: 4},
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
  
  { id: 38, number: 1, name: "A", conference_id: 8, room_id: 1},
  { id: 39, number: 2, name: "B", conference_id: 8, room_id: 2},
  { id: 40, number: 3, name: "C", conference_id: 8, room_id: 3},
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

if ENV['REVIEW_APP'] == 'true'
  import_dummy_data('cndt2020', %w(talks speakers talks_speakers))
  import_dummy_data('cndo2021', %w(talks speakers talks_speakers))
  import_dummy_data('cicd2021', %w(talks speakers talks_speakers proposals))
  import_dummy_data('cndt2021', %w(talks speakers talks_speakers proposals))
  import_dummy_data('o11y2022', %w(talks speakers talks_speakers proposals))
  import_dummy_data('cnsec2022', %w(talks speakers talks_speakers proposals proposal_items))
  import_dummy_data('cndt2022', %w(talks speakers talks_speakers proposals proposal_items))

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

  Announcement.seed(
    {id: 3, conference_id: 4, publish_time: "2021-10-11 10:00:00", publish: true, body: <<'EOS'
<a href="/cndt2021/" target="_blank">CloudNative Days Tokyo 2021</a>開催に向けて、10/18（月）19:00からプレイベントを実施します!
EOS
    }
  )
end

Ticket.seed(
  {id: "7b02e975-8418-4b40-a01d-f8011cc705e3", title: "オフライン参加", description: "aaaa", price: 0, stock: 454, conference_id: 7 },
  {id: "15ac6d96-5083-496d-9fd1-327f320a2f7b", title: "オンライン参加", description: "aaaa", price: 0, stock: 3500, conference_id: 7 },
  {id: "f4d09974-c6af-4fab-bb60-d394058e9eb8", title: "オフライン参加", description: "aaaa", price: 0, stock: 500, conference_id: 8 },
  {id: "5b31c315-5b70-4238-bf62-ed193480e9fd", title: "オンライン参加", description: "aaaa", price: 0, stock: 3500, conference_id: 8 },
)
