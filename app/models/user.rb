class User < ApplicationRecord
  has_many :profiles, dependent: :destroy
  has_many :speakers, dependent: :destroy
  has_many :sponsor_contacts, dependent: :destroy
  has_many :admin_profiles, dependent: :destroy

  validates :sub, presence: true, uniqueness: true
  validates :email, presence: true

  # Auth0の情報からUserを取得または作成
  def self.find_or_create_by_auth0_info(sub:, email:)
    find_or_create_by(sub:) do |user|
      user.email = email
    end
  end
end
