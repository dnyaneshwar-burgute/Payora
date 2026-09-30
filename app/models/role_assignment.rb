class RoleAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_by, class_name: "User"

  validates :effective_from, presence: true
  validates :effective_to, comparison: { greater_than: :effective_from }, allow_nil: true, if: -> { effective_from.present? }
  validate :user_and_role_belong_to_same_organization

  private

  def user_and_role_belong_to_same_organization
    return if user.blank? || role.blank? || role.platform_admin?
    return if user.organization_id == role.organization_id

    errors.add(:role, "must belong to the same organization as the user")
  end
end
