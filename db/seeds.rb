# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


if Industry.all.length == 0
  puts "Adding industry list"
  Industry.create!(
    [
      { name: "IT関連製造業" },
      { name: "電気機器製造業" },
      { name: "通信機器関連製造業" },
      { name: "電子部品/デバイス/電子回路製造業" },
      { name: "自動車/輸送用機器製造業" },
      { name: "産業用/事務用機器製造業" },
      { name: "食料品/飲料製造業" },
      { name: "医薬品/化学製品製造" },
      { name: "素材関連製造業" },
      { name: "その他の製造業" },
      { name: "ソフトウェアベンダー" },
      { name: "受託開発/情報処理サービス" },
      { name: "組み込み系ソフトウェア" },
      { name: "データセンター事業者" },
      { name: "クラウド系ベンダー" },
      { name: "SaaS系ベンダー" },
      { name: "Webサイト制作" },
      { name: "Webマーケティング支援" },
      { name: "通信事業者" },
      { name: "インターネットサービスプロバイダ" },
      { name: "その他の情報サービス業" },
      { name: "発電事業者" },
      { name: "一般送配電事業者" },
      { name: "小売電気事業者" },
      { name: "ガス/水道業" },
      { name: "その他の公益事業関連" },
      { name: "商社/販社/卸" },
      { name: "小売/流通（IT関連製品外）" },
      { name: "金融（銀行/証券/保険など）" },
      { name: "運輸/郵便業" },
      { name: "放送/出版/メディア" },
      { name: "インターネット関連メディア" },
      { name: "旅行/ホテル/レジャー業" },
      { name: "商社/販社/卸" },
      { name: "外食業" },
      { name: "広告代理店/PR会社" },
      { name: "印刷/DTP" },
      { name: "広告制作/デザイン" },
      { name: "専門職（弁護士/公認会計士/税理士など）" },
      { name: "コンサルティング" },
      { name: "その他のサービス業" },
      { name: "映像/音楽産業" },
      { name: "医療/福祉/病院" },
      { name: "農林/水産/鉱業" },
      { name: "建設業" },
      { name: "住宅/不動産" },
      { name: "政府/官公庁/団体" },
      { name: "地方自治体" },
      { name: "学校/教育機関" },
      { name: "研究所（民間/公共）" },
      { name: "自営業/独立事業者" },
      { name: "学生" },
      { name: "勤めていない" },
      { name: "該当なし" },
    ]
  )
end