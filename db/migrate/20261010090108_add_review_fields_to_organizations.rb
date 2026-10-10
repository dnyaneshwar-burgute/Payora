class AddReviewFieldsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :rejection_reason, :text

    reversible do |dir|
      dir.up do
        execute "UPDATE organizations SET status = 'approved' WHERE status = 'active'"
        execute "UPDATE organizations SET status = 'created' WHERE status NOT IN ('created', 'approved', 'rejected')"
      end
    end

    change_column_default :organizations, :status, from: nil, to: "created"

    add_check_constraint :organizations,
      "status IN ('created', 'approved', 'rejected')",
      name: "organizations_status_values"

    add_check_constraint :organizations,
      "status <> 'rejected' OR rejection_reason IS NOT NULL",
      name: "organizations_rejection_reason_required_when_rejected"
  end
end
