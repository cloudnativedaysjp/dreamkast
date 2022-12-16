namespace :util do
  desc 'generate_lead_cndt2022'
  task generate_lead_cndt2022: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cndt2022')

    attr = [
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
      '職種',
      '役職区分'
    ]

    conference.sponsors.each do |s|
      talk_id = s.talks[0]&.id || 0
      event_id = conference.id
      sponsor_types = s.sponsor_types.map(&:name)

      # target_sponsor_type = sponsor_types & ['Diamond','Platinum', 'Gold', 'Silver']
      target_sponsor_type = sponsor_types & ['Platinum']

      threshold = ['f5', 'techmatrix', 'acquia', 'freee'].include?(s.abbr) ? 1 : 5

      attr += ['メールを希望', '電話を希望'] if ['ibm', 'redhat'].include?(s.abbr)

      if target_sponsor_type.any?
        generated_csv = CSV.generate do |csv|
          csv << attr
          Profile.includes(:profile_survey).where(conference_id: event_id).includes(:registered_talks, :audience_counts).each do |profile|
            flagged = false
            if target_sponsor_type[0] == 'Diamond' ||
               (target_sponsor_type[0] == 'Platinum' && (profile.registered_talks.where(talk_id:).exists? || profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists?)) ||
               (target_sponsor_type[0] == 'Platinum' && (profile.registered_talks.where(talk_id:).exists? || profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists?))
              flagged = true
            end
            line = [
              profile.registered_talks.where(talk_id:).exists? ? 1 : 0,
              profile.audience_counts.where("talk_id = #{talk_id} AND  min > #{threshold}").exists? ? 1 : 0,
              profile.check_ins.find_by(ticket_id: '7b02e975-8418-4b40-a01d-f8011cc705e3').present? ? 1 : 0,
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
              profile.profile_survey&.industry,
              profile.profile_survey&.department,
              profile.profile_survey&.occupation,
              profile.profile_survey&.position
            ]
            if s.abbr == 'ibm'
              line.append(profile.agreements.where(form_item_id: 6)&.present? ? 1 : 0)
              line.append(profile.agreements.where(form_item_id: 7)&.present? ? 1 : 0)
            end

            if s.abbr == 'redhat'
              line.append(profile.agreements.where(form_item_id: 8)&.present? ? 1 : 0)
              line.append(profile.agreements.where(form_item_id: 9)&.present? ? 1 : 0)
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
