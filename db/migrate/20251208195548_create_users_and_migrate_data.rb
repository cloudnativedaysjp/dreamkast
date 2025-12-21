class CreateUsersAndMigrateData < ActiveRecord::Migration[8.0]
  def up
    # MySQLではDDL操作（CREATE TABLE等）はトランザクション内でもロールバックされないため、
    # エラー時に手動でクリーンアップする必要がある
    begin
      # 1. usersテーブルを作成
      create_table :users do |t|
        t.string :sub, null: false, limit: 250
        t.string :email, null: false
        t.timestamps
      end

      add_index :users, :sub, unique: true

      # 2. 各ロールテーブルにuser_idカラムを追加（null許可）
      add_column :profiles, :user_id, :bigint, null: true
      add_column :speakers, :user_id, :bigint, null: true
      add_column :sponsor_contacts, :user_id, :bigint, null: true
      add_column :admin_profiles, :user_id, :bigint, null: true

      # 3. データ移行を実行
      migrate_data

      # 4. user_idにnot null制約を追加。speakerとsponsor_contactは招待機能をサポートするためnull許可にしておく
      change_column_null :profiles, :user_id, false
      change_column_null :admin_profiles, :user_id, false

      # 5. 重複データをクリーンアップ（user_idとconference_idの組み合わせが重複している場合）
      cleanup_duplicate_profiles

      # 6. 外部キー制約を追加
      add_foreign_key :profiles, :users
      add_foreign_key :speakers, :users
      add_foreign_key :sponsor_contacts, :users
      add_foreign_key :admin_profiles, :users

      # 7. インデックスを追加
      add_index :profiles, [:user_id, :conference_id], unique: true

      # 8. 不要なカラムを削除
      remove_column :profiles, :sub
      remove_column :profiles, :email
      remove_column :speakers, :sub
      remove_column :speakers, :email
      remove_column :admin_profiles, :sub
      remove_column :admin_profiles, :email
      remove_column :sponsor_contacts, :sub
      remove_column :sponsor_contacts, :email

    rescue StandardError => e
      # エラー発生時は、作成されたusersテーブルをクリーンアップ
      # 外部キー制約を削除（存在する場合）
      remove_foreign_key :profiles, :users if foreign_key_exists?(:profiles, :users)
      remove_foreign_key :speakers, :users if foreign_key_exists?(:speakers, :users)
      remove_foreign_key :sponsor_contacts, :users if foreign_key_exists?(:sponsor_contacts, :users)
      remove_foreign_key :admin_profiles, :users if foreign_key_exists?(:admin_profiles, :users)
      # インデックスを削除（存在する場合）
      remove_index :profiles, [:user_id, :conference_id] if index_exists?(:profiles, [:user_id, :conference_id])
      # 追加したuser_idカラムを削除
      remove_column :profiles, :user_id if column_exists?(:profiles, :user_id)
      remove_column :speakers, :user_id if column_exists?(:speakers, :user_id)
      remove_column :sponsor_contacts, :user_id if column_exists?(:sponsor_contacts, :user_id)
      remove_column :admin_profiles, :user_id if column_exists?(:admin_profiles, :user_id)
      # usersテーブルを削除
      drop_table :users if table_exists?(:users)
      # エラーを再発生させてマイグレーションを失敗させる
      raise e
    end
  end

  def down
    transaction do
      # インデックスを削除
      remove_index :profiles, [:user_id, :conference_id] if index_exists?(:profiles, [:user_id, :conference_id])

      # 外部キー制約を削除
      remove_foreign_key :profiles, :users if foreign_key_exists?(:profiles, :users)
      remove_foreign_key :speakers, :users if foreign_key_exists?(:speakers, :users)
      remove_foreign_key :sponsor_contacts, :users if foreign_key_exists?(:sponsor_contacts, :users)
      remove_foreign_key :admin_profiles, :users if foreign_key_exists?(:admin_profiles, :users)

      # user_idカラムを削除
      remove_column :profiles, :user_id if column_exists?(:profiles, :user_id)
      remove_column :speakers, :user_id if column_exists?(:speakers, :user_id)
      remove_column :sponsor_contacts, :user_id if column_exists?(:sponsor_contacts, :user_id)
      remove_column :admin_profiles, :user_id if column_exists?(:admin_profiles, :user_id)

      # usersテーブルを削除
      drop_table :users if table_exists?(:users)
    end
  end

  private

  def migrate_data
    # モデルのカラム情報をリセット
    Profile.reset_column_information
    Speaker.reset_column_information
    SponsorContact.reset_column_information
    AdminProfile.reset_column_information
    User.reset_column_information

    # subとemailの組み合わせを収集
    user_data = {}

    puts "profile without sub #{Profile.where(sub: nil).count}"
    puts "profile without email #{Profile.where(email: nil).count}"
    puts "speaker without sub #{Speaker.where(sub: nil).count}"
    puts "speaker without email #{Speaker.where(email: nil).count}"
    puts "sponsor contact without sub #{SponsorContact.where(sub: nil).count}"
    puts "sponsor contact without email #{SponsorContact.where(email: nil).count}"
    puts "admin profile without sub #{AdminProfile.where(sub: nil).count}"
    puts "admin profile without email #{AdminProfile.where(email: nil).count}"

    puts "Start migrate profiles"
    # Profileから収集
    # マイグレーション中はdelegateを回避して直接カラムにアクセス
    Profile.where.not(sub: nil).find_each do |profile|
      sub = profile.read_attribute(:sub)
      email = profile.read_attribute(:email) || ''
      user_data[sub] ||= { email: email, sub: sub }
      raise "Found profile that sub or email is nil" if sub.blank? || email.blank?
    end

    puts "Finish migrate profiles"

    puts "Start migrate speakers"
    # Speakerから収集
    # マイグレーション中はdelegateを回避して直接カラムにアクセス
    Speaker.where.not(sub: nil).each do |speaker|
      sub = speaker.read_attribute(:sub)
      email = speaker.read_attribute(:email) || ''
      user_data[sub] ||= { email: email, sub: sub }
      raise "Found speaker that sub or email is nil" if sub.blank? || email.blank?
    end

    puts "Finish migrate speakers"

    puts "Start migrate sponsor contacts"

    # SponsorContactから収集
    # マイグレーション中はdelegateを回避して直接カラムにアクセス
    SponsorContact.where.not(sub: nil).each do |sponsor_contact|
      sub = sponsor_contact.read_attribute(:sub)
      email = sponsor_contact.read_attribute(:email) || ''
      user_data[sub] ||= { email: email, sub: sub }
      raise "Found sponsor contact that sub or email is nil" if sub.blank? || email.blank?
    end

    puts "Finish migrate sponsor contacts"

    puts "Start migrate admin profiles"

    # AdminProfileから収集
    # マイグレーション中はdelegateを回避して直接カラムにアクセス
    AdminProfile.where.not(sub: nil).each do |admin_profile|
      sub = admin_profile.read_attribute(:sub)
      email = admin_profile.read_attribute(:email) || ''
      user_data[sub] ||= { email: email, sub: sub }
      raise "Found admin profile that sub or email is nil" if sub.blank? || email.blank?
    end

    puts "Finish migrate admin profiles"

    puts "Start create users"

    # Userを作成（subが重複しないように）
    # usersテーブルは常に空から始まるため、バッチインサートで一括作成
    now = Time.current
    users_to_insert = user_data.map do |sub, data|
      {
        sub: sub,
        email: data[:email],
        created_at: now,
        updated_at: now
      }
    end

    # バッチインサート
    User.insert_all(users_to_insert) if users_to_insert.any?

    # 作成されたUserのIDを取得してuser_mapを構築
    # MySQLではreturning句がサポートされていないため、別途取得
    subs = user_data.keys
    user_map = User.where(sub: subs).pluck(:id, :sub).map { |id, sub| [sub, id] }.to_h

    puts "Finish create users"

    puts "Start set user_id to profiles"
    # 各ロールテーブルのuser_idを設定
    # Profile
    Profile.where(user_id: nil).find_each do |profile|
      sub = profile.read_attribute(:sub)
      if user_map[sub]
        profile.update_column(:user_id, user_map[sub])
      end
    end

    puts "Finish set user_id to profiles"

    puts "Start set user_id to speakers"

    # Speaker
    Speaker.where(user_id: nil).find_each do |speaker|
      sub = speaker.read_attribute(:sub)
      if user_map[sub]
        speaker.update_column(:user_id, user_map[sub])
      end
    end

    puts "Finish set user_id to speakers"

    puts "Start set user_id to sponsor contacts"

    # SponsorContact
    SponsorContact.where(user_id: nil).find_each do |sponsor_contact|
      sub = sponsor_contact.read_attribute(:sub)
      if user_map[sub]
        sponsor_contact.update_column(:user_id, user_map[sub])
      end
    end

    puts "Finish set user_id to sponsor contacts"

    puts "Start set user_id to admin profiles"

    # AdminProfile
    AdminProfile.where(user_id: nil).find_each do |admin_profile|
      sub = admin_profile.read_attribute(:sub)
      if user_map[sub]
        admin_profile.update_column(:user_id, user_map[sub])
      end
    end

    raise "Profile without user_id #{Profile.where(user_id: nil).count}" if Profile.where(user_id: nil).count > 0
    raise "Admin profile without user_id #{AdminProfile.where(user_id: nil).count}" if AdminProfile.where(user_id: nil).count > 0

    puts "Finish set user_id to admin profiles"
  end

  def cleanup_duplicate_profiles
    puts "Start cleanup duplicate profiles"
    
    # user_idとconference_idの組み合わせで重複を検出
    duplicates = Profile
      .where.not(user_id: nil)
      .group(:user_id, :conference_id)
      .having('COUNT(*) > 1')
      .pluck(:user_id, :conference_id)
    
    if duplicates.any?
      puts "Found #{duplicates.count} duplicate profile groups"
      
      duplicates.each do |user_id, conference_id|
        # 同じuser_idとconference_idを持つプロファイルを取得（ID順でソート）
        profiles = Profile.where(user_id: user_id, conference_id: conference_id).order(:id)

        puts "  profiles: #{profiles.count}"
        profiles.each do |profile|
          puts "    profile: #{profile.id}"
          puts "    profile.user_id: #{profile.user_id}"
          puts "    profile.conference_id: #{profile.conference_id}"
          puts "    profile.sub: #{profile.sub}"
          puts "    profile.email: #{profile.email}"
          puts "    profile.check_in_conferences: #{profile.check_in_conferences.count}"
          puts "    profile.check_in_talks: #{profile.check_in_talks.count}"
          puts "    profile.check_ins: #{profile.check_ins.count}"
          puts "    profile.form_values: #{profile.form_values.count}"
          puts "    profile.public_profile: #{profile.public_profile}"
          puts "    profile.registered_talks: #{profile.registered_talks.count}"
          puts "    profile.stamp_rally_check_ins: #{profile.stamp_rally_check_ins.count}"

        end

        # check_in_talksが多い方を残して
        keep_profile = profiles.max_by { |profile| profile.check_in_talks.count }
        delete_profiles = profiles.reject { |profile| profile.id == keep_profile.id }

        puts "  Keeping profile id=#{keep_profile.id}, deleting #{delete_profiles.count} duplicate(s) for user_id=#{user_id}, conference_id=#{conference_id}"
        
        delete_profiles.each do |profile|
          # 削除するプロファイルに関連するデータを削除
          delete_related_data(profile.id)
          
          # プロファイルを削除（deleteを使用してコールバックを回避）
          profile.delete
        end
      end
    else
      puts "No duplicate profiles found"
    end
    
    puts "Finish cleanup duplicate profiles"
  end

  def delete_related_data(profile_id)
    # 削除するプロファイルに関連するデータを削除
    # マイグレーション中は直接SQLを使用して効率的に削除
    
    tables_to_delete = [
      { table: :chat_messages, column: :profile_id },
      { table: :check_in_conferences, column: :profile_id },
      { table: :check_in_talks, column: :profile_id },
      { table: :check_ins, column: :profile_id },
      { table: :form_values, column: :profile_id },
      { table: :public_profiles, column: :profile_id },
      { table: :registered_talks, column: :profile_id },
      { table: :stamp_rally_check_ins, column: :profile_id }
    ]
    
    tables_to_delete.each do |config|
      next unless table_exists?(config[:table])
      next unless column_exists?(config[:table], config[:column])
      
      execute("DELETE FROM #{config[:table]} WHERE #{config[:column]} = #{profile_id}")
    end
    
    # scanner_profile_idをNULLに設定（check_in_conferences と check_in_talks）
    # レコード自体は残し、スキャンした人の情報だけを削除
    [:check_in_conferences, :check_in_talks].each do |table|
      next unless table_exists?(table)
      next unless column_exists?(table, :scanner_profile_id)
      
      execute("UPDATE #{table} SET scanner_profile_id = NULL WHERE scanner_profile_id = #{profile_id}")
    end
  end
end

