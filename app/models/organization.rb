class Organization < ApplicationRecord
  has_many :roles, dependent: :destroy, inverse_of: :organization
  has_many :departments, dependent: :delete_all, inverse_of: :organization

  validates :name, presence: true
  validates :host, presence: true, uniqueness: true
  validates :status, presence: true
end
