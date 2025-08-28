
DUMMY_TEXT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

Conference.seed(
  {
    id: 1,
    name: "CloudNative Days Tokyo 2020",
    abbr: "cndt2020",
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    conference_status: "migrated",
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
    capacity: 100,
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
    name: "CloudNative Days Tokyo 2023",
    abbr: "cndt2023",
    theme: "+Native ともに飛び出せ！",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Committee",
    capacity: 400,
    about: <<'EOS'
    "CloudNative Days"は、技術を学び、技術と人・人と人の繋がりを深めるテックカンファレンスです。
    コロナ禍で生じたコミュニティの分断を乗り越え、一体感を再び取り戻し、仲間や友達と共に成長しましょう。
    今回は分断されたコミュニティを再集結するための一歩として、東京で開催します!
    みなさんの所属組織の垣根を飛び越え、CloudNativeを元に交流する場に飛び込みませんか？
    "CloudNative"を学び、新たな世界に飛び出しませんか？
    さあ、ともに飛び出しましょう。
    "CloudNative Days"で、新たな繋がりと成長をお楽しみください。
EOS
  },
  {
    id: 11,
    name: "CloudNative Days Summer 2024",
    abbr: "cnds2024",
    theme: "Synergy 〜その先の、道へ。出会いと変化を紡ぐ場所〜",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Committee",
    capacity: 300,
    about: <<'EOS'
    この夏、CloudNative Daysは札幌という新天地で次の旅路をはじめます。
    初めての地で、さまざまな背景や経験を持つ参加者が集まり、新たな学び、繋がりを築きます。

    参加者の中には、あなた自身と、あるいは所属組織と<br/>同じ悩みや境遇を抱える方がいるかもしれません。
    また、新たな一歩を踏み出せずにいる人もいることでしょう。

    共感し合える仲間と出会い、時間を分かち合うことで新たなアイデアを創造したり、
    先駆者の知見に触れることで次の道を探るための場がここにはあります。

    出会いと変化を紡ぎ、未来への一歩を踏み出す1日にしましょう。
    さぁ、その先の、道へ。
EOS
  },
  {
    id: 12,
    name: "CloudNative Days Winter 2024",
    abbr: "cndw2024",
    theme: "小さな一歩、大きな飛躍〜クラウドネイティブを継続する",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Committee",
    capacity: 300,
    about: <<'EOS'
    クラウドネイティブをこれから始める人
    今まさに取り組んでいる人
    一定の成果を達成して、次のステップに迷っている人
    CloudNative Daysには様々な人が集まります。

    エンジニアも組織も、そしてシステムも
    クラウドネイティブから実りを得るには
    一度きりではなく、学びと改善を何度も繰り返す
    継続的な取り組みが重要です。

    小さな一歩を踏み出すのをためらわないでください。
    小さくても歩みを止めないでください。
    継続することをやめなければ、変化と経験の蓄積が
    やがて大きな飛躍をもたらします。

    そしてコミュニティが知見とモチベーションの交換を通して
    あなたの一歩を後押しします。
    CloudNative Daysは、クラウドネイティブへの小さな一歩を踏み出し、
    大きな飛躍へと前進するエンジニアと共に歩んでいきます。
EOS
  },
  {
    id: 110,
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
  {
    id: 13,
    name: "CloudNative Days Summer 2025",
    abbr: "cnds2025",
    theme: "Passion ~ CloudNativeに熱中する ~",
    copyright: '© CloudNative Days (Secretariat by Impress Corporation)',
    coc: File.read(File.join(Rails.root, 'db/fixtures/production/coc.md')),
    committee_name: "CloudNative Days Committee",
    capacity: 300,
    about: <<'EOS'
    今年、CloudNativeはさらなる広がりを見せ、その魅力は多くの人々の情熱を掻き立てています。
    推しのプロダクトをとことん使い込んでいたり、OSSの開発に熱中するエンジニアたちが集まり、
    その知見や思いを共有し合うことで新たな発想や出会いが生まれていくのです。
    
    2025年は、日本でCloudNativeがいっそう盛り上がる、まさに"情熱"に満ちた年となるでしょう。
    コミュニティに加わることで、人生や仕事に新たな刺激を得て、より豊かで充実した日々を過ごせるはずです。
    
    ここには、同じ思いを抱く仲間との出会いがあり、成長のきっかけが無数に散りばめられています。
    一人ひとりの情熱と行動が重なり合うことで、未来を拓くためのアイデアやイノベーションが紡がれていくでしょう。
    
    さぁ、CloudNativeに熱中する旅へ踏み出しましょう。
    私たちの情熱が、新しい世界と可能性を切り拓いていくのです。
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
  {id: 25, date: "2023-08-03", start_time: "10:50", end_time: "18:40", conference_id: 9, internal: false},
  {id: 26, date: "2023-06-22", start_time: "12:00", end_time: "18:00", conference_id: 9, internal: true},  # Reherasal

  # CNDT2023
  {id: 27, date: "2023-12-11", start_time: "10:00", end_time: "18:00", conference_id: 10, internal: false},
  {id: 28, date: "2023-12-12", start_time: "10:00", end_time: "18:00", conference_id: 10, internal: false}, 
  {id: 29, date: "2023-11-20", start_time: "12:00", end_time: "18:00", conference_id: 10, internal: true},  # Pre event

  # CNDS2024
  {id: 30, date: "2024-06-14", start_time: "10:20", end_time: "18:00", conference_id: 11, internal: true},
  {id: 31, date: "2024-06-15", start_time: "10:20", end_time: "18:00", conference_id: 11, internal: false}, 

  # CNDW2024
  {id: 32, date: "2024-11-28", start_time: "09:50", end_time: "18:00", conference_id: 12, internal: false},
  {id: 33, date: "2024-11-29", start_time: "09:50", end_time: "18:00", conference_id: 12, internal: false},

  # CNDS2025
  {id: 34, date: "2025-05-23", start_time: "10:20", end_time: "18:00", conference_id: 13, internal: false}
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
  { id: 9, conference_id: 7, name: "Red Hatからの電話を希望する"},
  { id: 10, conference_id: 13, name: "推しのOSS名(あれば)", attr: "oss_name"},
  { id: 11, conference_id: 13, name: "推しのOSSのURL", attr: "oss_url"},
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

  { id: 41, number: 1, name: "A", conference_id: 9, room_id: 14},
  { id: 42, number: 2, name: "B", conference_id: 9, room_id: 15},
  { id: 43, number: 3, name: "C", conference_id: 9, room_id: 16},

  { id: 44, number: 1, name: "A", conference_id: 10, room_id: 17},
  { id: 45, number: 2, name: "B", conference_id: 10, room_id: 18},
  { id: 46, number: 3, name: "C", conference_id: 10, room_id: 19},
  { id: 47, number: 4, name: "D", conference_id: 10, room_id: 20},

  { id: 48, number: 1, name: "A", conference_id: 11, room_id: 21},
  { id: 49, number: 2, name: "B", conference_id: 11, room_id: 22},
  { id: 50, number: 3, name: "C", conference_id: 11, room_id: 23},

  { id: 51, number: 1, name: "A", conference_id: 12, room_id: 24},
  { id: 52, number: 2, name: "B", conference_id: 12, room_id: 25},
  { id: 53, number: 3, name: "C", conference_id: 12, room_id: 26},
  { id: 54, number: 4, name: "D", conference_id: 12, room_id: 27},

  # CNDS2025
  { id: 55, number: 1, name: "A", conference_id: 13, room_id: 28},
  { id: 56, number: 2, name: "B", conference_id: 13, room_id: 29},
  { id: 57, number: 3, name: "C", conference_id: 13, room_id: 30}
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
  {id: 14, conference_id: 9, name: 'A-204'},
  {id: 15, conference_id: 9, name: 'B-206A'},
  {id: 16, conference_id: 9, name: 'C-202'},
  {id: 17, conference_id: 10, name: 'A-Room1'},
  {id: 18, conference_id: 10, name: 'B-Room2'},
  {id: 19, conference_id: 10, name: 'C-Boardroom'},
  {id: 20, conference_id: 10, name: 'D-Room6'},
  {id: 21, conference_id: 11, name: 'A'},
  {id: 22, conference_id: 11, name: 'B'},
  {id: 23, conference_id: 11, name: 'C'},
  {id: 24, conference_id: 12, name: 'A-Room1'},
  {id: 25, conference_id: 12, name: 'B-Room2'},
  {id: 26, conference_id: 12, name: 'C-Boardroom'},
  {id: 27, conference_id: 12, name: 'D-Room6'},

  # CNDS2025
  {id: 28, conference_id: 13, name: 'A'},
  {id: 29, conference_id: 13, name: 'B'},
  {id: 30, conference_id: 13, name: 'C'},
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

  { id: 91, conference_id: 10, name: "CI / CD"},
  { id: 92, conference_id: 10, name: "Customizing / Extending"},
  { id: 93, conference_id: 10, name: "IoT / Edge"},
  { id: 94, conference_id: 10, name: "Microservices / Services Mesh"},
  { id: 95, conference_id: 10, name: "ML / HPC"},
  { id: 96, conference_id: 10, name: "Networking"},
  { id: 97, conference_id: 10, name: "Operation / Monitoring / Logging"},
  { id: 98, conference_id: 10, name: "Application / Development"},
  { id: 99, conference_id: 10, name: "Runtime"},
  { id: 100, conference_id: 10, name: "Security"},
  { id: 101, conference_id: 10, name: "Serverless / FaaS"},
  { id: 102, conference_id: 10, name: "Storage / Database"},
  { id: 103, conference_id: 10, name: "Architecture Design"},
  { id: 104, conference_id: 10, name: "Hybrid Cloud / Multi Cloud"},
  { id: 105, conference_id: 10, name: "NFV / Edge"},
  { id: 106, conference_id: 10, name: "組織論"},
  { id: 107, conference_id: 10, name: "その他"},
  { id: 108, conference_id: 10, name: "Keynote"},

  { id: 109, conference_id: 11, name: "CI / CD"},
  { id: 110, conference_id: 11, name: "Customizing / Extending"},
  { id: 111, conference_id: 11, name: "IoT / Edge"},
  { id: 112, conference_id: 11, name: "Microservices / Services Mesh"},
  { id: 113, conference_id: 11, name: "ML / HPC"},
  { id: 114, conference_id: 11, name: "Networking"},
  { id: 115, conference_id: 11, name: "Operation / Monitoring / Logging"},
  { id: 116, conference_id: 11, name: "Application / Development"},
  { id: 117, conference_id: 11, name: "Runtime"},
  { id: 118, conference_id: 11, name: "Security"},
  { id: 119, conference_id: 11, name: "Serverless / FaaS"},
  { id: 120, conference_id: 11, name: "Storage / Database"},
  { id: 121, conference_id: 11, name: "Architecture Design"},
  { id: 122, conference_id: 11, name: "Hybrid Cloud / Multi Cloud"},
  { id: 123, conference_id: 11, name: "NFV / Edge"},
  { id: 124, conference_id: 11, name: "組織論"},
  { id: 125, conference_id: 11, name: "その他"},
  { id: 126, conference_id: 11, name: "Keynote"},

  { id: 127, conference_id: 12, name: "CI / CD"},
  { id: 128, conference_id: 12, name: "Customizing / Extending"},
  { id: 129, conference_id: 12, name: "IoT / Edge"},
  { id: 130, conference_id: 12, name: "Microservices / Services Mesh"},
  { id: 131, conference_id: 12, name: "ML / HPC"},
  { id: 132, conference_id: 12, name: "Networking"},
  { id: 133, conference_id: 12, name: "Operation / Monitoring / Logging"},
  { id: 134, conference_id: 12, name: "Application / Development"},
  { id: 135, conference_id: 12, name: "Runtime"},
  { id: 136, conference_id: 12, name: "Security"},
  { id: 137, conference_id: 12, name: "Serverless / FaaS"},
  { id: 138, conference_id: 12, name: "Storage / Database"},
  { id: 139, conference_id: 12, name: "Architecture Design"},
  { id: 140, conference_id: 12, name: "Hybrid Cloud / Multi Cloud"},
  { id: 141, conference_id: 12, name: "NFV / Edge"},
  { id: 142, conference_id: 12, name: "組織論"},
  { id: 143, conference_id: 12, name: "FinOps"},
  { id: 144, conference_id: 12, name: "その他"},
  { id: 145, conference_id: 12, name: "Keynote"},

  # CNDS2025
  { id: 146, conference_id: 13, name: "CI / CD"},
  { id: 147, conference_id: 13, name: "Customizing / Extending"},
  { id: 148, conference_id: 13, name: "IoT / Edge"},
  { id: 149, conference_id: 13, name: "Microservices / Services Mesh"},
  { id: 150, conference_id: 13, name: "ML / HPC"},
  { id: 151, conference_id: 13, name: "Networking"},
  { id: 152, conference_id: 13, name: "Operation / Monitoring / Logging"},
  { id: 153, conference_id: 13, name: "Application / Development"},
  { id: 154, conference_id: 13, name: "Runtime"},
  { id: 155, conference_id: 13, name: "Security"},
  { id: 156, conference_id: 13, name: "Serverless / FaaS"},
  { id: 157, conference_id: 13, name: "Storage / Database"},
  { id: 158, conference_id: 13, name: "Architecture Design"},
  { id: 159, conference_id: 13, name: "Hybrid Cloud / Multi Cloud"},
  { id: 160, conference_id: 13, name: "NFV / Edge"},
  { id: 161, conference_id: 13, name: "組織論"},
  { id: 162, conference_id: 13, name: "FinOps"},
  { id: 163, conference_id: 13, name: "その他"},
  { id: 164, conference_id: 13, name: "Keynote"}
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
  { id: 27, conference_id: 110, name: "初級者"},
  { id: 28, conference_id: 110, name: "中級者"},
  { id: 29, conference_id: 110, name: "上級者"},
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
  { id: 63, conference_id: 10, name: "初級者"},
  { id: 64, conference_id: 10, name: "中級者"},
  { id: 65, conference_id: 10, name: "上級者"},
  { id: 66, conference_id: 11, name: "初級者"},
  { id: 67, conference_id: 11, name: "中級者"},
  { id: 68, conference_id: 11, name: "上級者"},
  { id: 69, conference_id: 12, name: "初級者"},
  { id: 70, conference_id: 12, name: "中級者"},
  { id: 71, conference_id: 12, name: "上級者"},

  # CNDS2025
  { id: 72, conference_id: 13, name: "初級者"},
  { id: 73, conference_id: 13, name: "中級者"},
  { id: 74, conference_id: 13, name: "上級者"}
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

 Talk::Type.seed(
  {
        id: 'Session',
        display_name: '公募セッション',
        description: '公募セッション',
        is_exclusive: false
      },
      {
        id: 'KeynoteSession',
        display_name: 'キーノート',
        description: 'メインの基調講演',
        is_exclusive: false
      },
      {
        id: 'SponsorSession',
        display_name: 'スポンサーセッション',
        description: 'スポンサー企業によるセッション',
        is_exclusive: false
      },
      {
        id: 'Intermission',
        display_name: '休憩',
        description: '休憩時間',
        is_exclusive: true
      }
 )
# import_dummy_data('cndt2020', %w(talks speakers talks_speakers))
# import_dummy_data('cndo2021', %w(talks speakers talks_speakers))
# import_dummy_data('cicd2021', %w(talks speakers talks_speakers proposals))
# import_dummy_data('cndt2021', %w(talks speakers talks_speakers proposals))
# import_dummy_data('o11y2022', %w(talks speakers talks_speakers proposals))
# import_dummy_data('cnsec2022', %w(talks speakers talks_speakers proposals proposal_items))
# import_dummy_data('cndt2022', %w(talks speakers talks_speakers proposals proposal_items))
# import_dummy_data('cicd2023', %w(talks speakers talks_speakers proposals proposal_items))
# import_dummy_data('cndf2023', %w(talks speakers talks_speakers proposals proposal_items))
# import_dummy_data('cndt2023', %w(talks speakers talks_speakers proposals proposal_items))
# import_dummy_data('cnds2024', %w(talks speakers talks_speakers proposals proposal_items))
import_dummy_data('cndw2024', %w(talks speakers talks_speakers proposals proposal_items))
import_dummy_data('cnds2025', %w(talks speakers talks_speakers proposals proposal_items))

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
  { id: 1, talk_id: 1, site: "vimeo", video_id: "444387842", on_air: true},
  { id: 2, talk_id: 2, site: "vimeo", video_id: "442363621", on_air: true},
  { id: 3, talk_id: 3, site: "vimeo", video_id: "334092219", on_air: true},
  { id: 4, talk_id: 4, site: "vimeo", video_id: "410005892", on_air: true},
  { id: 5, talk_id: 5, site: "vimeo", video_id: "303648115", on_air: true},
  { id: 6, talk_id: 6, site: "vimeo", video_id: "417159783", on_air: true},
  { id: 7, talk_id: 7, site: "vimeo", video_id: "442385897", on_air: false},
  { id: 8, talk_id: 8, site: "vimeo", video_id: "444712888", on_air: false},
  { id: 9, talk_id: 9, site: "vimeo", video_id: "443856794", on_air: false},
  { id: 10, talk_id: 65, site: "vimeo", video_id: "442956490", on_air: false},
  { id: 11, talk_id: 68, site: "vimeo", video_id: "442956490", on_air: false},
)


Link.seed(
  {id: 1, title: "link 1", url: "https://example.com", description: "this is description", conference_id: 1},
  {id: 2, title: "link 2", url: "https://example.com", description: "this is description", conference_id: 1},
  {id: 3, title: "link 3", url: "https://example.com", description: "this is description", conference_id: 1}
)


Video.seed(
  { id: 1, talk_id: 1, site: "vimeo", video_id: "444387842", on_air: true},
  { id: 2, talk_id: 2, site: "vimeo", video_id: "442363621", on_air: true},
  { id: 3, talk_id: 3, site: "vimeo", video_id: "334092219", on_air: true},
  { id: 4, talk_id: 4, site: "vimeo", video_id: "410005892", on_air: true},
  { id: 5, talk_id: 5, site: "vimeo", video_id: "303648115", on_air: true},
  { id: 6, talk_id: 6, site: "vimeo", video_id: "417159783", on_air: true},
  { id: 7, talk_id: 7, site: "vimeo", video_id: "442385897", on_air: false},
  { id: 8, talk_id: 8, site: "vimeo", video_id: "444712888", on_air: false},
  { id: 9, talk_id: 9, site: "vimeo", video_id: "443856794", on_air: false},
  { id: 10, talk_id: 65, site: "vimeo", video_id: "442956490", on_air: false},
  { id: 11, talk_id: 68, site: "vimeo", video_id: "442956490", on_air: false},
)


Link.seed(
  {id: 1, title: "link 1", url: "https://example.com", description: "this is description", conference_id: 1},
  {id: 2, title: "link 2", url: "https://example.com", description: "this is description", conference_id: 1},
  {id: 3, title: "link 3", url: "https://example.com", description: "this is description", conference_id: 1}
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
},
  {id: 3, conference_id: 4, publish_time: "2021-10-11 10:00:00", publish: true, body: <<'EOS'
<a href="/cndt2021/" target="_blank">CloudNative Days Tokyo 2021</a>開催に向けて、10/18（月）19:00からプレイベントを実施します!
EOS
}
)
