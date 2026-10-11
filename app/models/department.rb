class Department < ApplicationRecord
  scoped_to_organization

  belongs_to :organization, inverse_of: :departments
  belongs_to :parent, class_name: "Department", optional: true

  has_many :children, class_name: "Department", foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error

  validates :name, presence: true
  validate :parent_belongs_to_same_organization

  private

  def parent_belongs_to_same_organization
    if parent_id.present? && parent_id == id
      errors.add(:parent, "can't be the department itself")
      return
    end

    return if parent.blank? || parent.organization_id == organization_id

    errors.add(:parent, "must belong to the same organization")
  end
end
