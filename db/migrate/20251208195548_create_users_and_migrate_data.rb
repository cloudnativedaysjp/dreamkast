class CreateUsersAndMigrateData < ActiveRecord::Migration[8.0]
  def up
    # トランザクション内で全ての処理を実行
    transaction do
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

      # 5. 外部キー制約を追加
      add_foreign_key :profiles, :users
      add_foreign_key :speakers, :users
      add_foreign_key :sponsor_contacts, :users
      add_foreign_key :admin_profiles, :users

      # 6. インデックスを追加
      add_index :profiles, [:user_id, :conference_id], unique: true

      # 7. 不要なカラムを削除
      remove_column :profiles, :sub
      remove_column :profiles, :email
      remove_column :speakers, :sub
      remove_column :speakers, :email
      remove_column :admin_profiles, :sub
      remove_column :admin_profiles, :email
      remove_column :sponsor_contacts, :sub
      remove_column :sponsor_contacts, :email
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

    # Profileから収集
    Profile.where.not(sub: nil).find_each do |profile|
      sub = profile.sub
      email = profile.email || ''
      user_data[sub] ||= { email: email, sub: sub }
      # emailが空の場合は、最初に見つかったemailを使用
      user_data[sub][:email] = email if email.present? && user_data[sub][:email].blank?
    end

    # Speakerから収集
    Speaker.where.not(sub: nil).find_each do |speaker|
      sub = speaker.sub
      email = speaker.email || ''
      user_data[sub] ||= { email: email, sub: sub }
      # emailが空の場合は、最初に見つかったemailを使用
      user_data[sub][:email] = email if email.present? && user_data[sub][:email].blank?
    end

    # SponsorContactから収集
    SponsorContact.where.not(sub: nil).find_each do |sponsor_contact|
      sub = sponsor_contact.sub
      email = sponsor_contact.email || ''
      user_data[sub] ||= { email: email, sub: sub }
      # emailが空の場合は、最初に見つかったemailを使用
      user_data[sub][:email] = email if email.present? && user_data[sub][:email].blank?
    end

    # AdminProfileから収集
    AdminProfile.where.not(sub: nil).find_each do |admin_profile|
      sub = admin_profile.sub
      email = admin_profile.email || ''
      user_data[sub] ||= { email: email, sub: sub }
      # emailが空の場合は、最初に見つかったemailを使用
      user_data[sub][:email] = email if email.present? && user_data[sub][:email].blank?
    end

    # Userを作成（subが重複しないように）
    user_map = {}
    user_data.each do |sub, data|
      # emailが空の場合は、subをemailとして使用（一時的な対応）
      email = data[:email].present? ? data[:email] : "#{sub}@temp.local"
      
      user = User.find_or_create_by(sub: sub) do |u|
        u.email = email
      end
      # emailが更新された場合は更新
      if user.email.blank? || user.email == "#{sub}@temp.local"
        user.update(email: email) if email.present? && email != "#{sub}@temp.local"
      end
      user_map[sub] = user.id
    end

    # 各ロールテーブルのuser_idを設定
    # Profile
    Profile.where.not(sub: nil).find_each do |profile|
      if user_map[profile.sub]
        profile.update_column(:user_id, user_map[profile.sub])
      end
    end

    # Speaker
    Speaker.where.not(sub: nil).find_each do |speaker|
      if user_map[speaker.sub]
        speaker.update_column(:user_id, user_map[speaker.sub])
      end
    end

    # SponsorContact
    SponsorContact.where.not(sub: nil).find_each do |sponsor_contact|
      if user_map[sponsor_contact.sub]
        sponsor_contact.update_column(:user_id, user_map[sponsor_contact.sub])
      end
    end

    # AdminProfile
    AdminProfile.where.not(sub: nil).find_each do |admin_profile|
      if user_map[admin_profile.sub]
        admin_profile.update_column(:user_id, user_map[admin_profile.sub])
      end
    end

    # subがnullのレコードを処理（一時的なUserを作成）
    # Profile
    Profile.where(sub: nil).find_each do |profile|
      # emailから一時的なUserを作成
      if profile.email.present?
        temp_sub = "temp_#{profile.id}_#{SecureRandom.hex(8)}"
        user = User.create!(sub: temp_sub, email: profile.email)
        profile.update_column(:user_id, user.id)
      end
    end

    # Speaker
    Speaker.where(sub: nil).find_each do |speaker|
      # emailから一時的なUserを作成
      if speaker.email.present?
        temp_sub = "temp_#{speaker.id}_#{SecureRandom.hex(8)}"
        user = User.create!(sub: temp_sub, email: speaker.email)
        speaker.update_column(:user_id, user.id)
      end
    end

    # SponsorContact
    SponsorContact.where(sub: nil).find_each do |sponsor_contact|
      # emailから一時的なUserを作成
      if sponsor_contact.email.present?
        temp_sub = "temp_#{sponsor_contact.id}_#{SecureRandom.hex(8)}"
        user = User.create!(sub: temp_sub, email: sponsor_contact.email)
        sponsor_contact.update_column(:user_id, user.id)
      end
    end

    # AdminProfile
    AdminProfile.where(sub: nil).find_each do |admin_profile|
      # emailから一時的なUserを作成
      if admin_profile.email.present?
        temp_sub = "temp_#{admin_profile.id}_#{SecureRandom.hex(8)}"
        user = User.create!(sub: temp_sub, email: admin_profile.email)
        admin_profile.update_column(:user_id, user.id)
      else
        # subもemailもnullの場合は、一時的なUserを作成
        temp_sub = "temp_#{admin_profile.id}_#{SecureRandom.hex(8)}"
        temp_email = "temp_#{admin_profile.id}@temp.local"
        user = User.create!(sub: temp_sub, email: temp_email)
        admin_profile.update_column(:user_id, user.id)
      end
    end

    # subもemailもnullのレコードを処理（最後に処理）
    # Profile
    Profile.where(sub: nil).where("email IS NULL OR email = ''").find_each do |profile|
      temp_sub = "temp_#{profile.id}_#{SecureRandom.hex(8)}"
      temp_email = "temp_#{profile.id}@temp.local"
      user = User.create!(sub: temp_sub, email: temp_email)
      profile.update_column(:user_id, user.id)
    end

    # Speaker
    Speaker.where(sub: nil).where("email IS NULL OR email = ''").find_each do |speaker|
      temp_sub = "temp_#{speaker.id}_#{SecureRandom.hex(8)}"
      temp_email = "temp_#{speaker.id}@temp.local"
      user = User.create!(sub: temp_sub, email: temp_email)
      speaker.update_column(:user_id, user.id)
    end

    # SponsorContact
    SponsorContact.where(sub: nil).where("email IS NULL OR email = ''").find_each do |sponsor_contact|
      temp_sub = "temp_#{sponsor_contact.id}_#{SecureRandom.hex(8)}"
      temp_email = "temp_#{sponsor_contact.id}@temp.local"
      user = User.create!(sub: temp_sub, email: temp_email)
      sponsor_contact.update_column(:user_id, user.id)
    end
  end
end

