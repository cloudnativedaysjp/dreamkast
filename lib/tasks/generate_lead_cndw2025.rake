namespace :util do
  desc 'generate_lead_cndw2025'
  task generate_lead_cndw2025: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cndw2025')
    track_viewer = TrackViewer.connection.execute("SELECT * FROM track_viewer WHERE created_at > '2025-11-17'")

    attr = [
      '申し込み種別：現地',
      '申し込み種別：オンライン',
      'イベント参加',
      '内、現地チェックイン',
      'セッション登録フラグ',
      '現地セッション視聴フラグ',
      'オンラインセッション視聴フラグ',
      '姓',
      '名',
      'セイ',
      'メイ',
      '会社名/所属団体名',
      '所属部署名',
      '郵便番号',
      '都道府県',
      '勤務先住所1（都道府県以下）',
      '勤務先住所2（ビル名）',
      '電話番号',
      'FAX番号',
      'メールアドレス（PC）',
      '従業員数',
      '年商規模',
      '業種',
      '所属部署',
      '職種'
    ]

    conference.sponsors.each do |s|
      talk_id = s.talks[0]&.id || 0
      event_id = conference.id
      sponsor_types = s.sponsor_types.map(&:name)

      target_sponsor_type = sponsor_types & ['Diamond', 'Platinum', 'Gold']

      if target_sponsor_type.any?
        generated_csv = CSV.generate do |csv|
          csv << attr
          Profile.where(conference_id: event_id).includes(:registered_talks).each do |profile|
            checkin = 0
            flag = true
            attended = track_viewer.any? { |row| row[2] == profile.id } || profile.check_ins.present?
            if s.abbr == 'グラファナラボ日本' || s.abbr == 'レッドハット'
              unless profile.check_in_conferences[0].nil? || profile.check_in_conferences[0].created_at < '2025/11/18 2:50:00'
                checkin = 1
              end
            else
              checkin = profile.check_in_talks.where(talk_id:).present? ? 1 : 0
            end
            if target_sponsor_type.include?('Gold') && !attended
              flag = false
            end
            line = [
              profile.offline? ? 1 : 0,
              profile.online? ? 1 : 0,
              attended ? 1 : 0,
              profile.check_in_conferences.present? ? 1 : 0,
              profile.registered_talks.where(talk_id:).exists? ? 1 : 0,
              checkin,
              track_viewer.any? { |row| row[2] == profile.id && row[3] == talk_id } ? 1 : 0,
              profile.last_name,
              profile.first_name,
              profile.last_name_kana,
              profile.first_name_kana,
              [profile.company_name_prefix&.name, profile.company_name, profile.company_name_suffix&.name].join,
              profile.department,
              profile.company_postal_code,
              profile.company_address_level1,
              profile.company_address_level2 + profile.company_address_line1,
              profile.company_address_line2,
              profile.company_tel,
              profile.company_fax,
              profile.company_email,
              FormModels::NumberOfEmployee.find(profile.number_of_employee_id).name,
              FormModels::AnnualSales.find(profile.annual_sales_id).name,
              profile.industry_name,
              profile.department,
              profile.position
            ]
            csv << line if flag
          end
        end
        File.open("./tmp/csv/#{target_sponsor_type[0]}_#{s.abbr}_#{talk_id}.csv", 'w', encoding: 'UTF-8') do |file|
          file.write(generated_csv)
        end
      end
    end
  end
end
