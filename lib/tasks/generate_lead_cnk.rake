namespace :util do
  desc 'generate_lead_cnk'
  task generate_lead_cnk: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference_abbr = ENV.fetch('CONFERENCE_ABBR', 'cnk')
    conference = Conference.find_by(abbr: conference_abbr)
    abort("Conference with abbr='#{conference_abbr}' was not found. Set CONFERENCE_ABBR to a valid event abbreviation.") unless conference

    # Pre-load TrackViewer data
    # Store as a hash for O(1) lookup: { profile_id => { talk_id => true } }
    # Also keep a set of profile_ids for "attended" check
    track_viewer_rows = TrackViewer.connection.execute("SELECT profile_id, talk_id FROM track_viewer WHERE created_at > '2026-05-13'")
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
      'ブース読み取り',
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
                      .includes(:registered_talks, :check_ins, :check_in_conferences, :check_in_talks, :stamp_rally_check_ins)
                      .to_a

    # check_point_id => sponsor_id のマップ（ブースのみ）
    check_point_sponsor_map = StampRallyCheckPointBooth.where(conference_id: conference.id)
                                                       .pluck(:id, :sponsor_id)
                                                       .to_h

    # Gold だが Booth 扱いにするスポンサー（セッション参加ではなくブース読み取りでフィルタ）
    booth_treatment_gold_sponsors = [
      'KINTOテクノロジーズ株式会社',
      '株式会社 日立製作所',
      'Okta Japan株式会社'
    ]

    conference.sponsors.each do |s|
      talk_id = s.talks[0]&.id || 0
      sponsor_types = s.sponsor_types.map(&:name)

      target_sponsor_type = sponsor_types & %w[Diamond Gold Booth]
      treat_as_booth = booth_treatment_gold_sponsors.include?(s.name)

      booth_output = target_sponsor_type == ['Booth'] || treat_as_booth

      next unless target_sponsor_type.any?

      # Booth 出力の場合は「申し込み種別：現地」〜「オンラインセッション視聴フラグ」までを省略
      header = booth_output ? attr.drop(8) : attr

      generated_csv = CSV.generate do |csv|
        csv << header

        profiles.each do |profile|
          # イベント参加判定:
          #   - オンライン視聴履歴がある（登録区分問わず）
          #   - もしくは 現地参加登録 かつ 現地チェックイン履歴あり
          has_track_viewer_log = track_viewer_attended_profiles.include?(profile.id)
          has_offline_check_in = profile.offline? && profile.check_in_conferences.present?
          attended = has_track_viewer_log || has_offline_check_in
          checkin = profile.check_in_talks.any? { |t| t.talk_id == talk_id } ? 1 : 0

          booth_scanned = profile.stamp_rally_check_ins.any? { |ci| check_point_sponsor_map[ci.stamp_rally_check_point_id] == s.id }

          # Filter for Gold: Must have attended the specific session (Online or Offline)
          online_session_attended = track_viewer_data[profile.id].include?(talk_id)
          offline_session_attended = profile.check_in_talks.any? { |t| t.talk_id == talk_id }
          session_attended = online_session_attended || offline_session_attended

          # Filter for Gold: 対象セッション参加者のみ
          next if target_sponsor_type.include?('Gold') && !treat_as_booth && !session_attended

          # Filter for Booth (純粋な Booth スポンサー or Booth 扱いの Gold): ブース読み取りが必要
          next if (target_sponsor_type == ['Booth'] || treat_as_booth) && !booth_scanned

          # Helper for industry name lookup
          industry_name = industries[profile.industry_id]&.name || ''

          # Helper for company name
          company_full_name = [
            profile.company_name_prefix&.name,
            profile.company_name,
            profile.company_name_suffix&.name
          ].join

          flag_columns =
            if booth_output
              []
            else
              [
                profile.offline? ? 1 : 0,
                profile.online? ? 1 : 0,
                attended ? 1 : 0,
                has_offline_check_in ? 1 : 0,
                profile.registered_talks.any? { |t| t.talk_id == talk_id } ? 1 : 0,
                checkin,
                booth_scanned ? 1 : 0,
                online_session_attended ? 1 : 0
              ]
            end

          line = flag_columns + [
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

      # Ensure directory exists
      FileUtils.mkdir_p('./tmp/csv')
      File.open("./tmp/csv/#{target_sponsor_type[0]}_#{s.name}_#{s.id}.csv", 'w', encoding: 'UTF-8') do |file|
        file.write(generated_csv)
      end
    end
  end
end
