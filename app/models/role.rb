class Role < ApplicationRecord
  belongs_to :organization, optional: true, inverse_of: :roles

  enum :kind, {
    platform_admin: "platform_admin",
    organization_owner: "organization_owner",
    custom: "custom"
  }

  validates :name, :key, presence: true
  validates :organization, absence: true, if: :platform_admin?
  validates :organization, presence: true, unless: :platform_admin?
  validates :key, uniqueness: { scope: :organization_id }
end
