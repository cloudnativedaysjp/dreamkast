class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_many :speakers, dependent: :destroy
  has_one :sponsor_contact, dependent: :destroy
  has_one :admin_profile, dependent: :destroy

  validates :sub, presence: true, uniqueness: true
  validates :email, presence: true

  # Auth0の情報からUserを取得または作成
  def self.find_or_create_by_auth0_info(sub:, email:)
    find_or_create_by(sub:) do |user|
      user.email = email
    end
  end
end
