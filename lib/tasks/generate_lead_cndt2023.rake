namespace :util do
  desc 'generate_lead_cndt2023'
  task generate_lead_cndt2023: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cndt2023')
    diamond_attr = [
      '申し込み種別：現地',
      '申し込み種別：オンライン',
      'イベント参加',
      '内、現地チェックイン',
      'セッション登録フラグ',
      'セッション視聴フラグ'
    ]

    other_attr = [
      '申し込み種別：現地',
      '申し込み種別：オンライン',
      'イベント参加',
      '内、現地チェックイン',
      'セッション登録フラグ',
      'セッション視聴フラグ'
    ]

    base_attr = [
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
      '職種',
    ]

    conference.sponsors.each do |s|
      talk_id = s.talks[0]&.id || 0
      event_id = conference.id
      sponsor_types = s.sponsor_types.map(&:name)

      target_sponsor_type = sponsor_types & ['Diamond', 'Platinum', 'Gold']
      threshold = 1

      if target_sponsor_type.any?
        generated_csv = CSV.generate do |csv|
          attr = []
          if target_sponsor_type == ['Diamond']
            attr = diamond_attr + base_attr
          else
            attr = other_attr + base_attr
          end
          attr << 'メールを希望' if s.abbr == 'レッドハット'
          attr << '電話を希望' if s.abbr == 'レッドハット'
          csv << attr
          Profile.where(conference_id: event_id).includes(:registered_talks, :audience_counts).each do |profile|
            flagged = false
            if profile.registered_talks.where(talk_id:).exists? || profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? || profile.check_ins.present? || target_sponsor_type == ['Diamond']
              flagged = true
            end
            if target_sponsor_type == ['Diamond']
              flagged_line = [
                profile.offline? ? 1 : 0,
                profile.online? ? 1 : 0,
                profile.audience_counts.where("min > #{threshold}").exists? || profile.check_ins.present? ? 1 : 0,
                profile.check_ins.present? ? 1 : 0,
                profile.registered_talks.where(talk_id:).exists? ? 1 : 0,
                profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? ? 1 : 0,
              ]
            else
              flagged_line = [
                profile.offline? ? 1 : 0,
                profile.online? ? 1 : 0,
                profile.audience_counts.where("min > #{threshold}").exists? || profile.check_ins.present? ? 1 : 0,
                profile.check_ins.present? ? 1 : 0,
                profile.registered_talks.where(talk_id:).exists? ? 1 : 0,
                profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? ? 1 : 0,
              ]
            end
            base_line = [
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
            line = flagged_line + base_line
            if s.abbr == 'レッドハット'
              line << (profile.agreements.where(form_item_id: 8)&.present? ? 1 : 0)
              line << (profile.agreements.where(form_item_id: 9)&.present? ? 1 : 0)
            end
            csv << line if flagged
          end
        end
        File.open("./tmp/csv/#{target_sponsor_type[0]}_#{s.abbr}_#{talk_id}.csv", 'w', encoding: 'UTF-8') do |file|
          file.write(generated_csv)
        end
      end
    end
  end
end
