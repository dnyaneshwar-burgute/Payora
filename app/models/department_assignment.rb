class DepartmentAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :department
  belongs_to :assigned_by, class_name: "User"

  validates :effective_from, presence: true
  validates :effective_to, comparison: { greater_than: :effective_from }, allow_nil: true, if: -> { effective_from.present? }
  validate :user_and_department_belong_to_same_organization

  private

  def user_and_department_belong_to_same_organization
    return if user.blank? || department.blank? || user.organization_id == department.organization_id

    errors.add(:department, "must belong to the same organization as the user")
  end
end
