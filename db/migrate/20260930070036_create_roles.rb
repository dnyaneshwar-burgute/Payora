class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.string :kind, null: false
      t.boolean :system, null: false, default: false
      t.references :organization, null: true, foreign_key: true

      t.timestamps
    end

    add_index :roles, :kind, unique: true, where: "kind = 'platform_admin'", name: "index_roles_on_platform_admin_kind"
    add_index :roles, [ :organization_id, :key ], unique: true

    add_check_constraint :roles,
      "kind IN ('platform_admin', 'organization_owner', 'custom')",
      name: "roles_kind_values"

    add_check_constraint :roles,
      "(kind = 'platform_admin' AND organization_id IS NULL) OR (kind <> 'platform_admin' AND organization_id IS NOT NULL)",
      name: "roles_organization_required_unless_platform_admin"

    add_check_constraint :roles,
      "(kind IN ('platform_admin', 'organization_owner') AND system) OR (kind = 'custom' AND NOT system)",
      name: "roles_system_matches_kind"

    reversible do |dir|
      dir.up do
        Role.reset_column_information
        Role.find_or_create_by!(kind: "platform_admin") do |role|
          role.name = "Platform Admin"
          role.key = "platform_admin"
          role.system = true
        end
      end
    end
  end
end
