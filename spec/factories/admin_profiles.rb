def ensure_user_for_admin_profile(admin_profile)
  return if admin_profile.user_id.present?

  if admin_profile.sub.present?
    user = User.find_or_create_by!(sub: admin_profile.sub) do |u|
      u.email = admin_profile.email || "#{admin_profile.sub}@example.com"
    end
  elsif admin_profile.email.present?
    # subがnilの場合は、emailから一時的なUserを作成
    temp_sub = "temp_#{SecureRandom.hex(8)}"
    user = User.find_or_create_by!(email: admin_profile.email) do |u|
      u.sub = temp_sub
    end
  else
    # subもemailもnilの場合は、一時的なUserを作成
    temp_sub = "temp_#{SecureRandom.hex(8)}"
    temp_email = "temp_#{SecureRandom.hex(8)}@temp.local"
    user = User.create!(sub: temp_sub, email: temp_email)
  end
  admin_profile.user_id = user.id
end

FactoryBot.define do
  factory :admin_profile do
    after(:build) do |admin_profile|
      ensure_user_for_admin_profile(admin_profile)
    end

    before(:create) do |admin_profile|
      ensure_user_for_admin_profile(admin_profile)
    end
  end
end
