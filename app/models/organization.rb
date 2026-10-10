class Organization < ApplicationRecord
  has_many :roles, dependent: :destroy, inverse_of: :organization
  has_many :departments, dependent: :delete_all, inverse_of: :organization
  has_many :users, dependent: :restrict_with_error, inverse_of: :organization

  accepts_nested_attributes_for :users

  normalizes :host, with: ->(host) { host.strip.downcase }

  validates :name, presence: true
  validates :host, presence: true, uniqueness: true
  validates :status, presence: true
end
