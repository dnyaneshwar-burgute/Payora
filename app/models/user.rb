class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :organization, inverse_of: :users
  belongs_to :parent, class_name: "User", optional: true
  has_many :children, class_name: "User", foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :phone_number, with: ->(phone) { phone.strip.presence }

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: { with: /\A\+?[0-9][0-9\s\-()]{6,19}\z/ }, allow_blank: true
  validate :parent_belongs_to_same_organization

  private

  def parent_belongs_to_same_organization
    if parent_id.present? && parent_id == id
      errors.add(:parent, "can't be the user itself")
      return
    end

    return if parent.blank? || parent.organization_id == organization_id

    errors.add(:parent, "must belong to the same organization")
  end
end
