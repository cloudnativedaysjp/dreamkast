namespace :util do
  desc 'generate_lead_cndw2025'
  task generate_lead_cndw2025: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cndw2025')
    
    # Pre-load TrackViewer data
    # Store as a hash for O(1) lookup: { profile_id => { talk_id => true } }
    # Also keep a set of profile_ids for "attended" check
    track_viewer_rows = TrackViewer.connection.execute("SELECT profile_id, talk_id FROM track_viewer WHERE created_at > '2025-11-17'")
    track_viewer_data = Hash.new { |h, k| h[k] = Set.new }
    track_viewer_attended_profiles = Set.new
    
    track_viewer_rows.each do |row|
      # row is likely an array or hash depending on the adapter
      # Assuming row indexes based on SELECT order: 0=profile_id, 1=talk_id
      if row.is_a?(Array)
        pid = row[0]
        tid = row[1]
      else
        pid = row['profile_id']
        tid = row['talk_id']
      end
      
      track_viewer_data[pid].add(tid)
      track_viewer_attended_profiles.add(pid)
    end

    # Pre-load FormModels to avoid N+1
    employees = FormModels::NumberOfEmployee.all.index_by(&:id)
    annual_sales = FormModels::AnnualSales.all.index_by(&:id)
    # Industry is a bit complex in Profile#industry_name, but we can cache the flattened list
    industries = FormModels::Industry.all.map { |i| i.attributes[:child] }.flatten.index_by(&:id)

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

    # Pre-load Profiles with necessary associations
    profiles = Profile.where(conference_id: conference.id)
                      .includes(:registered_talks, :check_ins, :check_in_conferences, :check_in_talks)
                      .to_a

    conference.sponsors.each do |s|
      talk_id = s.talks[0]&.id || 0
      sponsor_types = s.sponsor_types.map(&:name)

      target_sponsor_type = sponsor_types & ['Diamond', 'Platinum', 'Gold']

      if target_sponsor_type.any?
        generated_csv = CSV.generate do |csv|
          csv << attr
          
          profiles.each do |profile|
            checkin = 0
            flag = true
            
            # Optimization: Use pre-loaded data
            has_track_viewer_log = track_viewer_attended_profiles.include?(profile.id)
            has_check_in = profile.check_ins.present?
            attended = has_track_viewer_log || has_check_in

            if s.abbr == 'グラファナラボ日本' || s.abbr == 'レッドハット'
              # Optimization: check_in_conferences is already loaded
              c_checkin = profile.check_in_conferences.first
              unless c_checkin.nil? || c_checkin.created_at < '2025/11/18 2:50:00'
                checkin = 1
              end
            else
              # Optimization: check_in_talks is loaded. Filter in memory.
              checkin = profile.check_in_talks.any? { |t| t.talk_id == talk_id } ? 1 : 0
            end

            # Filter for Gold/Platinum: Must have attended the specific session (Online or Offline)
            online_session_attended = track_viewer_data[profile.id].include?(talk_id)
            offline_session_attended = profile.check_in_talks.any? { |t| t.talk_id == talk_id }
            talks_registered = profile.registered_talks.any? { |t| t.talk_id == talk_id }
            session_attended = online_session_attended || offline_session_attended || talks_registered

            if (target_sponsor_type.include?('Gold') || target_sponsor_type.include?('Platinum')) && !session_attended
              flag = false
            end
            
            if flag
              # Helper for industry name lookup
              industry_name = industries[profile.industry_id]&.name || ''
              
              # Helper for company name
              company_full_name = [
                profile.company_name_prefix&.name, 
                profile.company_name, 
                profile.company_name_suffix&.name
              ].join

              line = [
                profile.offline? ? 1 : 0,
                profile.online? ? 1 : 0,
                attended ? 1 : 0,
                profile.check_in_conferences.present? ? 1 : 0,
                profile.registered_talks.any? { |t| t.talk_id == talk_id } ? 1 : 0,
                checkin,
                (track_viewer_data[profile.id]&.include?(talk_id) ? 1 : 0),
                profile.last_name,
                profile.first_name,
                profile.last_name_kana,
                profile.first_name_kana,
                company_full_name,
                profile.department,
                profile.company_postal_code,
                profile.company_address_level1,
                profile.company_address_level2 + profile.company_address_line1,
                profile.company_address_line2,
                profile.company_tel,
                profile.company_fax,
                profile.company_email,
                employees[profile.number_of_employee_id]&.name,
                annual_sales[profile.annual_sales_id]&.name,
                industry_name,
                profile.department,
                profile.position
              ]
              csv << line
            end
          end
        end
        
        # Ensure directory exists
        FileUtils.mkdir_p("./tmp/csv")
        File.open("./tmp/csv/#{target_sponsor_type[0]}_#{s.abbr}_#{talk_id}.csv", 'w', encoding: 'UTF-8') do |file|
          file.write(generated_csv)
        end
      end
    end
  end
end
