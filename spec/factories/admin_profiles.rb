FactoryBot.define do
  factory :admin_profile do
    after(:build) do |admin_profile|
      next if admin_profile.user_id.present?

      user = FactoryBot.create(:user)
      admin_profile.user_id = user.id
    end

    before(:create) do |admin_profile|
      next if admin_profile.user_id.present?

      user = FactoryBot.create(:user)
      admin_profile.user_id = user.id
    end
  end
end
