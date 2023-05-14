class FormModels::Industry < ActiveHash::Base
  IndustrySelect = Struct.new(:id, :name)

  self.data = [
    # { id: 1, name: '選択してください', disabled: true },
    { id: 2, name: '～製造業関連～', child: [
      IndustrySelect.new(id: 3, name: '電気機器製造業'),
      IndustrySelect.new(id: 4, name: '通信機器関連製造業'),
      IndustrySelect.new(id: 5, name: '電子部品/デバイス/電子回路製造業'),
      IndustrySelect.new(id: 6, name: '自動車/輸送用機器製造業'),
      IndustrySelect.new(id: 7, name: '産業用/事務用機器製造業'),
      IndustrySelect.new(id: 8, name: '食料品/飲料製造業'),
      IndustrySelect.new(id: 9, name: '医薬品/化学製品製造'),
      IndustrySelect.new(id: 10, name: '素材関連製造業'),
      IndustrySelect.new(id: 11, name: 'IT関連製造業'),
      IndustrySelect.new(id: 12, name: 'その他の製造業')
    ] },
    { id: 13, name: '～電気・ガス・水道業関連～', child: [
      IndustrySelect.new(id: 14, name: '発電事業者'),
      IndustrySelect.new(id: 15, name: '一般送配電事業者'),
      IndustrySelect.new(id: 16, name: '小売電気事業者'),
      IndustrySelect.new(id: 17, name: 'ガス/水道業'),
      IndustrySelect.new(id: 18, name: 'その他の公益事業関連')
    ] },
    { id: 19, name: '～流通・サービス業関連～', child: [
      IndustrySelect.new(id: 20, name: '商社/販社/卸'),
      IndustrySelect.new(id: 21, name: '小売/流通（IT関連製品外）'),
      IndustrySelect.new(id: 22, name: '金融（銀行/証券/保険など）'),
      IndustrySelect.new(id: 23, name: '運輸/郵便業'),
      IndustrySelect.new(id: 24, name: '放送/出版/メディア'),
      IndustrySelect.new(id: 25, name: 'インターネット関連メディア'),
      IndustrySelect.new(id: 26, name: '旅行/ホテル/レジャー業'),
      IndustrySelect.new(id: 27, name: '外食業'),
      IndustrySelect.new(id: 28, name: '広告代理店/PR会社'),
      IndustrySelect.new(id: 29, name: '印刷/DTP'),
      IndustrySelect.new(id: 30, name: '広告制作/デザイン'),
      IndustrySelect.new(id: 31, name: '専門職（弁護士/公認会計士/税理士など）'),
      IndustrySelect.new(id: 32, name: 'コンサルティング'),
      IndustrySelect.new(id: 33, name: 'その他のサービス業')
    ] },
    { id: 34, name: '～その他業種～', child: [
      IndustrySelect.new(id: 35, name: '映像/音楽産業'),
      IndustrySelect.new(id: 36, name: '医療/福祉/病院'),
      IndustrySelect.new(id: 37, name: '農林/水産/鉱業'),
      IndustrySelect.new(id: 38, name: '建設業'),
      IndustrySelect.new(id: 39, name: '住宅/不動産'),
      IndustrySelect.new(id: 40, name: '政府/官公庁/団体'),
      IndustrySelect.new(id: 41, name: '地方自治体'),
      IndustrySelect.new(id: 42, name: '学校/教育機関'),
      IndustrySelect.new(id: 43, name: '研究所（民間/公共）'),
      IndustrySelect.new(id: 44, name: '自営業/独立事業者'),
      IndustrySelect.new(id: 45, name: '学生'),
      IndustrySelect.new(id: 46, name: '勤めていない')
    ] },
    { id: 47, name: '～ITサービス業関連～', child: [
      IndustrySelect.new(id: 48, name: 'ソフトウェアベンダー'),
      IndustrySelect.new(id: 49, name: '受託開発/情報処理サービス'),
      IndustrySelect.new(id: 50, name: '組み込み系ソフトウェア'),
      IndustrySelect.new(id: 51, name: 'データセンター事業者'),
      IndustrySelect.new(id: 52, name: 'クラウド系ベンダー'),
      IndustrySelect.new(id: 53, name: 'SaaS系ベンダー'),
      IndustrySelect.new(id: 54, name: 'Webサイト制作'),
      IndustrySelect.new(id: 55, name: 'Webマーケティング支援'),
      IndustrySelect.new(id: 56, name: '通信事業者'),
      IndustrySelect.new(id: 57, name: 'インターネットサービスプロバイダ'),
      IndustrySelect.new(id: 58, name: 'その他の情報サービス業'),
      IndustrySelect.new(id: 59, name: '該当なし')
    ] }
  ]
end
