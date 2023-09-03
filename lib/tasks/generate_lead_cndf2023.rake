namespace :util do
  desc 'generate_lead_cndf2023'
  task generate_lead_cndf2023: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cndf2023')

    attr = [
      'イベント参加',
      'セッション登録フラグ',
      'セッション視聴フラグ',
      '現地チェックイン',
      '姓',
      '名',
      'セイ',
      'メイ',
      '前株',
      '会社名/所属団体名',
      '後株',
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

      target_sponsor_type = sponsor_types & ['Diamond', 'Platinum']
      #target_sponsor_type = sponsor_types & ['Platinum']

      #threshold = ['f5', 'techmatrix', 'acquia', 'freee'].include?(s.abbr) ? 1 : 5
      threshold = 1

      if target_sponsor_type.any?
        generated_csv = CSV.generate do |csv|
          csv << attr
          Profile.where(conference_id: event_id).includes(:registered_talks, :audience_counts).each do |profile|
            flagged = false
            if profile.registered_talks.where(talk_id:).exists? || profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? || profile.check_ins.find_by(ticket_id: 'a7a3e5d5-0d8e-1c29-1c29-7004affe194a').present?
              flagged = true
            end
            line = [
              #profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? || profile.check_ins.find_by(ticket_id: 'a7a3e5d5-0d8e-1c29-1c29-7004affe194a').present? ? 1 : 0,
              profile.audience_counts.where("min > #{threshold}").exists? || profile.check_ins.find_by(ticket_id: 'a7a3e5d5-0d8e-1c29-1c29-7004affe194a').present? ? 1 : 0,
              profile.registered_talks.where(talk_id:).exists? ? 1 : 0,
              profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? ? 1 : 0,
              profile.check_ins.find_by(ticket_id: 'a7a3e5d5-0d8e-1c29-1c29-7004affe194a').present? ? 1 : 0,
              profile.last_name,
              profile.first_name,
              profile.last_name_kana,
              profile.first_name_kana,
              profile.company_name_prefix&.name,
              profile.company_name,
              profile.company_name_suffix&.name,
              profile.department,
              profile.company_postal_code,
              profile.company_address_level1,
              profile.company_address_level2 + profile.company_address_line1,
              profile.company_address_line2,
              profile.company_tel,
              profile.company_fax,
              profile.company_email,
              profile.number_of_employee.name,
              profile.annual_sales.name,
              profile.industry_name,
              profile.department,
              profile.position
            ]
            csv << line if s.abbr != 'アクイアジャパン' || flagged
          end
        end
        File.open("./tmp/csv/#{target_sponsor_type[0]}_#{s.abbr}_#{talk_id}.csv", 'w', encoding: 'UTF-8') do |file|
          file.write(generated_csv)
        end
      end
    end
  end
end
