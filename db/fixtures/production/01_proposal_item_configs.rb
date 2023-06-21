ProposalItemConfig.seed(
  {
    id: 1,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'architect - システム設計'
  },
  {
    id: 2,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'developer - システム開発'
  },
  {
    id: 3,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'app-developer - アプリケーション開発'
  },
  {
    id: 4,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'operator/sys-admin - 運用管理/システム管理'
  },
  {
    id: 5,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'CxO/biz - ビジネス層'
  },
  {
    id: 6,
    conference_id: 3,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
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

  # =========== CICD2021 =============
  {
    id: 10,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'architect - システム設計'
  },
  {
    id: 11,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'developer - システム開発'
  },
  {
    id: 12,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'app-developer - アプリケーション開発'
  },
  {
    id: 13,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'operator/sys-admin - 運用管理/システム管理'
  },
  {
    id: 14,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'CxO/biz - ビジネス層'
  },
  {
    id: 15,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'その他'
  },

  {
    id: 16,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 2,
    item_name: '実行フェーズ（★★）',
    params: 'Dev/QA（開発環境）'
  },
  {
    id: 17,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 2,
    item_name: '実行フェーズ（★★）',
    params: 'PoC（検証）'
  },
  {
    id: 18,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 2,
    item_name: '実行フェーズ（★★）',
    params: 'Production（本番環境）'
  },
  {
    id: 19,
    conference_id: 4,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 2,
    item_name: '実行フェーズ（★★）',
    params: 'Other'
  },

  {
    id: 20,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'All okay - スライド・動画両方ともに公開可',
    description: 'イベント終了後に講演資料（スライドはslideshareなどにご自分でアップしてください）とアーカイブ動画を公開します。公開可否は来場者がセッションを選択する際の大きな判断材料となりますので事前に意思を確認させてください。動画はスライドと同期させた映像（例：https://www.youtube.com/watch?v=V21a3WMPC7s）を予定しています - After the event ends, we will publish the lecture materials (please upload yourself to slideshare etc) and archive videos. Please tell us in advance as visitors will be a big material to choose sessions.',
    key: VideoAndSlidePublished::ALL_OK,
    value: 'All okay - スライド・動画両方ともに公開可'
  },
  {
    id: 21,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'Only Slide - スライドのみ公開可',
    key: VideoAndSlidePublished::ONLY_SLIDE,
    value: 'Only Slide - スライドのみ公開可'
  },
  {
    id: 22,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'NG - いずれも公開不可（来場者限定のコンテンツ）',
    key: VideoAndSlidePublished::ALL_NG,
    value: 'NG - いずれも公開不可（来場者限定のコンテンツ）'
  },
  {
    id: 23,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'その他',
    key: VideoAndSlidePublished::OTHERS,
    value: 'その他'
  },

  {
    id: 24,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'session_time',
    item_number: 4,
    item_name: '必要とする講演時間 - Session time you need（★）',
    params: '40min (full session)',
    description: 'ワークショップやLTなどを希望される場合はその他に希望時間を記入してください - If you are requesting a workshop or LT etc, please fill in the desired time in addition'
  },
  {
    id: 25,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'session_time',
    item_number: 4,
    item_name: '必要とする講演時間 - Session time you need（★）',
    params: '20min (half session)'
  },

  {
    id: 26,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'language',
    item_number: 5,
    item_name: '講演言語 - Language（★）',
    params: 'JA',
    description: '英語での講演は、翻訳者や通訳機器の都合で会場やセッション時間に影響が出てくる可能性もあります - The session in English, may also affect the venue and session time'
  },
  {
    id: 27,
    conference_id: 4,
    type: 'ProposalItemConfigRadioButton',
    label: 'language',
    item_number: 5,
    item_name: '講演言語 - Language（★）',
    params: 'EN'
  },

  # o11y2022
  {
    id: 28,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'architect - システム設計'
  },
  {
    id: 29,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'developer - システム開発'
  },
  {
    id: 30,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'app-developer - アプリケーション開発'
  },
  {
    id: 31,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'operator/sys-admin - 運用管理/システム管理'
  },
  {
    id: 32,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'CxO/biz - ビジネス層'
  },
  {
    id: 33,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'その他'
  },
  {
    id: 34,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'Dev/QA（開発環境）'
  },
  {
    id: 35,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'PoC（検証）'
  },
  {
    id: 36,
    conference_id: 5,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'Production（本番環境）'
  },
  {
    id: 37,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'presentation_method',
    item_number: 6,
    item_name: '登壇方法の希望',
    params: '現地登壇'
  },
  {
    id: 38,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'presentation_method',
    item_number: 6,
    item_name: '登壇方法の希望',
    params: 'オンライン登壇'
  },
  {
    id: 39,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'presentation_method',
    item_number: 6,
    item_name: '登壇方法の希望',
    params: '事前収録'
  },
  {
    id: 40,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'All okay - スライド・動画両方ともに公開可',
    description: 'イベント終了後に講演資料（スライドはslideshareなどにご自分でアップしてください）とアーカイブ動画を公開します。公開可否は来場者がセッションを選択する際の大きな判断材料となりますので事前に意思を確認させてください。動画はスライドと同期させた映像（例：https://www.youtube.com/watch?v=V21a3WMPC7s）を予定しています - After the event ends, we will publish the lecture materials (please upload yourself to slideshare etc) and archive videos. Please tell us in advance as visitors will be a big material to choose sessions.'
  },
  {
    id: 41,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'Only Slide - スライドのみ公開可'
  },
  {
    id: 42,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'NG - いずれも公開不可（来場者限定のコンテンツ）'
  },
  {
    id: 43,
    conference_id: 5,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'その他'
  },

  # =========== CNSEC2021 =============
  {
    id: 44,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'architect - システム設計'
  },
  {
    id: 45,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'developer - システム開発'
  },
  {
    id: 46,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'app-developer - アプリケーション開発'
  },
  {
    id: 47,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'operator/sys-admin - 運用管理/システム管理'
  },
  {
    id: 48,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'CxO/biz - ビジネス層'
  },
  {
    id: 49,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'assumed_visitor',
    item_number: 1,
    item_name: '想定受講者（★★）',
    params: 'その他'
  },
  {
    id: 50,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'Dev/QA（開発環境）'
  },
  {
    id: 51,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'PoC（検証）'
  },
  {
    id: 52,
    conference_id: 6,
    type: 'ProposalItemConfigCheckBox',
    label: 'execution_phase',
    item_number: 5,
    item_name: '実行フェーズ（★★）',
    params: 'Production（本番環境）'
  },
  {
    id: 53,
    conference_id: 6,
    type: 'ProposalItemConfigRadioButton',
    label: 'presentation_method',
    item_number: 6,
    item_name: '登壇方法の希望',
    params: 'オンライン登壇'
  },
  {
    id: 54,
    conference_id: 6,
    type: 'ProposalItemConfigRadioButton',
    label: 'presentation_method',
    item_number: 6,
    item_name: '登壇方法の希望',
    params: '事前収録'
  },
  {
    id: 55,
    conference_id: 6,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    params: 'All okay - スライド・動画両方ともに公開可',
    key: 1,
    description: 'イベント終了後に講演資料（スライドはslideshareなどにご自分でアップしてください）とアーカイブ動画を公開します。公開可否は来場者がセッションを選択する際の大きな判断材料となりますので事前に意思を確認させてください。動画はスライドと同期させた映像（例：https://www.youtube.com/watch?v=V21a3WMPC7s）を予定しています - After the event ends, we will publish the lecture materials (please upload yourself to slideshare etc) and archive videos. Please tell us in advance as visitors will be a big material to choose sessions.'
  },
  {
    id: 56,
    conference_id: 6,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    key: 2,
    params: 'Only Slide - スライドのみ公開可'
  },
  {
    id: 57,
    conference_id: 6,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    key: 3,
    params: 'Only Movie - 動画のみ公開可'
  },
  {
    id: 58,
    conference_id: 6,
    type: 'ProposalItemConfigRadioButton',
    label: 'whether_it_can_be_published',
    item_number: 3,
    item_name: 'スライドと動画の公開可否（★★）',
    key: 4,
    params: 'NG - いずれも公開不可（来場者限定のコンテンツ）'
  }
)

# =========== CNDT2022 =============
def assumed_visitor(conference_id:, item_number:, items:)
  ProposalItemConfig.seed(
    items.map do |item|
      {
        id: item[:id],
        conference_id: conference_id,
        type: 'ProposalItemConfigCheckBox',
        label: 'assumed_visitor',
        item_number: item_number,
        item_name: '想定受講者（★★）',
        params: item[:params]
      }
    end
  )
end
def execution_phase(conference_id:, item_number:, items:)
  ProposalItemConfig.seed(
    items.map do |item|
      {
        id: item[:id],
        conference_id: conference_id,
        type: 'ProposalItemConfigCheckBox',
        label: 'execution_phase',
        item_number: item_number,
        item_name: '実行フェーズ（★★）',
        params: item[:params]
      }
    end
  )
end
def whether_it_can_be_published(conference_id:, item_number:, items:)
  ProposalItemConfig.seed(
    items.map do |item|
      {
        id: item[:id],
        conference_id: conference_id,
        type: 'ProposalItemConfigRadioButton',
        label: 'whether_it_can_be_published',
        item_number: item_number,
        item_name: 'スライドと動画の公開可否（★★）',
        params: item[:params],
        description: item[:description],
        key: item[:key],
        value: item[:value]
      }
    end
  )
end

def session_time(conference_id:, item_number:, items:)
  ProposalItemConfig.seed(
    items.map do |item|
      {
        id: item[:id],
        conference_id: conference_id,
        type: 'ProposalItemConfigRadioButton',
        label: 'session_time',
        item_number: item_number,
        item_name: '必要とする講演時間 - Session time you need（★）',
        params: item[:params],
        description: item[:description],
        key: item[:key],
        value: item[:params],
      }
    end
  )
end
def language(conference_id:, item_number:, items:)
  ProposalItemConfig.seed(
    items.map do |item|
      {
        id: item[:id],
        conference_id: conference_id,
        type: 'ProposalItemConfigRadioButton',
        label: 'language',
        item_number: item_number,
        item_name: '講演言語 - Language（★）',
        params: item[:params],
        description: item[:description],
      }
    end
  )
end

def presentation_method(conference_id:, item_number:, items:)
  ProposalItemConfig.seed(
    items.map do |item|
      {
        id: item[:id],
        conference_id: conference_id,
        type: 'ProposalItemConfigRadioButton',
        label: 'presentation_method',
        item_number: item_number,
        item_name: '登壇方法の希望',
        params: item[:params],
        description: item[:description],
      }
    end
  )
end

assumed_visitor(
  conference_id: 7,
  item_number: 1,
  items: [
    {id: 59, params: 'architect - システム設計'},
    {id: 60, params: 'developer - システム開発'},
    {id: 61, params: 'app-developer - アプリケーション開発'},
    {id: 62, params: 'operator/sys-admin - 運用管理/システム管理'},
    {id: 63, params: 'CxO/biz - ビジネス層'},
    {id: 64, params: 'その他'}
  ]
)

execution_phase(
  conference_id: 7,
  item_number: 2,
  items: [
    {id: 65, params: 'Dev/QA（開発環境）'},
    {id: 66, params: 'PoC（検証）'},
    {id: 67, params: 'Production（本番環境）'},
    {id: 68, params: 'Other'},
  ]
)

whether_it_can_be_published(
  conference_id: 7,
  item_number: 3,
  items: [
    {
      id: 69,
      params: 'All okay - スライド・動画両方ともに公開可',
      description: 'イベント終了後に講演資料（スライドはslideshareなどにご自分でアップしてください）とアーカイブ動画を公開します。公開可否は来場者がセッションを選択する際の大きな判断材料となりますので事前に意思を確認させてください。動画はスライドと同期させた映像（例：https://www.youtube.com/watch?v=V21a3WMPC7s）を予定しています - After the event ends, we will publish the lecture materials (please upload yourself to slideshare etc) and archive videos. Please tell us in advance as visitors will be a big material to choose sessions.',
      key: VideoAndSlidePublished::ALL_OK,
      value: 'All okay - スライド・動画両方ともに公開可'
    },
    {
      id: 70,
      params: 'Only Slide - スライドのみ公開可',
      description: '',
      key: VideoAndSlidePublished::ONLY_SLIDE,
      value: 'Only Slide - スライドのみ公開可'
    },
    {
      id: 71,
      params: 'NG - いずれも公開不可（来場者限定のコンテンツ）',
      description: '',
      key: VideoAndSlidePublished::ALL_NG,
      value: 'NG - いずれも公開不可（来場者限定のコンテンツ）'
    },
    {
      id: 72,
      params: 'その他',
      description: '',
      key: VideoAndSlidePublished::OTHERS,
      value: 'その他'
    }
  ]
)

presentation_method(
  conference_id: 7,
  item_number: 4,
  items: [
    {
      id: 73,
      params: '現地登壇',
      description: "プロポーザル採択後は登壇方法を変更することができません"
    },
    {
      id: 74,
      params: 'オンライン登壇',
      description: ''
    },
    {
      id: 75,
      params: '事前収録',
      description: ''
    },
  ]
)

session_time(
  conference_id: 7,
  item_number: 5,
  items: [
    {
      id: 76,
      key: SessionTime::FOURTY_MINUTES,
      params: '40min (full session)',
      description: [
        "20分のセッションは登壇方法が事前収録の時のみ選択できます"
      ].join("</br>")
    },
    {
      id: 77,
      key: SessionTime::TWENTY_MINUTES,
      params: '20min (half session)',
      description: ''
    }
  ]
)

language(
  conference_id: 7,
  item_number: 6,
  items: [
    {id: 78, params: 'JA', description: '英語での講演は、翻訳者や通訳機器の都合で会場やセッション時間に影響が出てくる可能性もあります - The session in English, may also affect the venue and session time'},
    {id: 79, params: 'EN'},
  ]
)

## CICD2023
assumed_visitor(
  conference_id: 8,
  item_number: 1,
  items: [
    {id: 80, params: 'architect - システム設計'},
    {id: 81, params: 'developer - システム開発'},
    {id: 82, params: 'app-developer - アプリケーション開発'},
    {id: 83, params: 'operator/sys-admin - 運用管理/システム管理'},
    {id: 84, params: 'CxO/biz - ビジネス層'},
    {id: 85, params: 'その他'}
  ]
)

execution_phase(
  conference_id: 8,
  item_number: 2,
  items: [
    {id: 86, params: 'Dev/QA（開発環境）'},
    {id: 87, params: 'PoC（検証）'},
    {id: 88, params: 'Production（本番環境）'},
    {id: 89, params: 'Other'},
  ]
)

whether_it_can_be_published(
  conference_id: 8,
  item_number: 3,
  items: [
    {
      id: 90,
      params: 'All okay - スライド・動画両方ともに公開可',
      description: 'イベント終了後に講演資料（スライドはslideshareなどにご自分でアップしてください）とアーカイブ動画を公開します。公開可否は来場者がセッションを選択する際の大きな判断材料となりますので事前に意思を確認させてください。動画はスライドと同期させた映像（例：https://www.youtube.com/watch?v=V21a3WMPC7s）を予定しています - After the event ends, we will publish the lecture materials (please upload yourself to slideshare etc) and archive videos. Please tell us in advance as visitors will be a big material to choose sessions.',
      key: VideoAndSlidePublished::ALL_OK,
      value: 'All okay - スライド・動画両方ともに公開可'
    },
    {
      id: 91,
      params: 'Only Slide - スライドのみ公開可',
      description: '',
      key: VideoAndSlidePublished::ONLY_SLIDE,
      value: 'Only Slide - スライドのみ公開可'
    },
    {
      id: 92,
      params: 'NG - いずれも公開不可（来場者限定のコンテンツ）',
      description: '',
      key: VideoAndSlidePublished::ALL_NG,
      value: 'NG - いずれも公開不可（来場者限定のコンテンツ）'
    },
    {
      id: 93,
      params: 'その他',
      description: '',
      key: VideoAndSlidePublished::OTHERS,
      value: 'その他'
    }
  ]
)

presentation_method(
  conference_id: 8,
  item_number: 4,
  items: [
    {
      id: 94,
      params: '現地登壇',
      description: "プロポーザル採択後は登壇方法を変更することができません"
    },
    # CICD2023はオンライン登壇無し
    {
      id: 95,
      params: '事前収録',
      description: ''
    },
  ]
)

session_time(
  conference_id: 8,
  item_number: 5,
  items: [
    {
      id: 96,
      key: SessionTime::FOURTY_MINUTES,
      params: '40min (full session)',
      description: ''
    }
  ]
)

language(
  conference_id: 8,
  item_number: 6,
  items: [
    {id: 97, params: 'JA', description: '英語での講演は、翻訳者や通訳機器の都合で会場やセッション時間に影響が出てくる可能性もあります - The session in English, may also affect the venue and session time'},
    {id: 98, params: 'EN'},
  ]
)

## CNDF2023
assumed_visitor(
  conference_id: 9,
  item_number: 1,
  items: [
    {id: 100, params: 'architect - システム設計'},
    {id: 101, params: 'developer - システム開発'},
    {id: 102, params: 'app-developer - アプリケーション開発'},
    {id: 103, params: 'operator/sys-admin - 運用管理/システム管理'},
    {id: 104, params: 'CxO/biz - ビジネス層'},
    {id: 105, params: 'その他'}
  ]
)

execution_phase(
  conference_id: 9,
  item_number: 2,
  items: [
    {id: 106, params: 'Dev/QA（開発環境）'},
    {id: 107, params: 'PoC（検証）'},
    {id: 108, params: 'Production（本番環境）'},
    {id: 109, params: 'Other'},
  ]
)

whether_it_can_be_published(
  conference_id: 9,
  item_number: 3,
  items: [
    {
      id: 110,
      params: 'All okay - スライド・動画両方ともに公開可',
      description: 'イベント終了後に講演資料（スライドはslideshareなどにご自分でアップしてください）とアーカイブ動画を公開します。公開可否は来場者がセッションを選択する際の大きな判断材料となりますので事前に意思を確認させてください。動画はスライドと同期させた映像（例：https://www.youtube.com/watch?v=V21a3WMPC7s）を予定しています - After the event ends, we will publish the lecture materials (please upload yourself to slideshare etc) and archive videos. Please tell us in advance as visitors will be a big material to choose sessions.',
      key: VideoAndSlidePublished::ALL_OK,
      value: 'All okay - スライド・動画両方ともに公開可'
    },
    {
      id: 111,
      params: 'Only Slide - スライドのみ公開可',
      description: '',
      key: VideoAndSlidePublished::ONLY_SLIDE,
      value: 'Only Slide - スライドのみ公開可'
    },
    {
      id: 112,
      params: 'NG - いずれも公開不可（来場者限定のコンテンツ）',
      description: '',
      key: VideoAndSlidePublished::ALL_NG,
      value: 'NG - いずれも公開不可（来場者限定のコンテンツ）'
    },
    {
      id: 113,
      params: 'その他',
      description: '',
      key: VideoAndSlidePublished::OTHERS,
      value: 'その他'
    }
  ]
)

presentation_method(
  conference_id: 9,
  item_number: 4,
  items: [
    {
      id: 114,
      params: '現地登壇',
      description: "プロポーザル採択後は登壇方法を変更することができません"
    },
    {
      id: 115,
      params: '事前収録',
      description: ''
    },
  ]
)

session_time(
  conference_id: 9,
  item_number: 5,
  items: [
    {
      id: 116,
      key: SessionTime::FOURTY_MINUTES,
      params: '40min (full session)',
      description: ''
    },
    {
      id: 119,
      key: SessionTime::TWENTY_MINUTES,
      params: '20min (for keynote)',
      description: ''
    }
  ]
)

language(
  conference_id: 9,
  item_number: 6,
  items: [
    {id: 117, params: 'JA', description: '英語での講演は、翻訳者や通訳機器の都合で会場やセッション時間に影響が出てくる可能性もあります - The session in English, may also affect the venue and session time'},
    {id: 118, params: 'EN'},
  ]
)