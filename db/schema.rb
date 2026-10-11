# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_10_090109) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "department_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "department_id", null: false
    t.datetime "effective_from", null: false
    t.datetime "effective_to"
    t.bigint "assigned_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_department_assignments_on_assigned_by_id"
    t.index ["department_id"], name: "index_department_assignments_on_department_id"
    t.index ["user_id"], name: "index_department_assignments_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_departments_on_organization_id"
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.bigint "invited_by_id", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["role_id"], name: "index_invitations_on_role_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "host", null: false
    t.string "status", default: "created", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "rejection_reason"
    t.index ["host"], name: "index_organizations_on_host", unique: true
    t.check_constraint "status::text <> 'rejected'::text OR rejection_reason IS NOT NULL", name: "organizations_rejection_reason_required_when_rejected"
    t.check_constraint "status::text = ANY (ARRAY['created'::character varying, 'approved'::character varying, 'rejected'::character varying]::text[])", name: "organizations_status_values"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "effective_from", null: false
    t.datetime "effective_to"
    t.bigint "assigned_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_role_assignments_on_assigned_by_id"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["user_id"], name: "index_role_assignments_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.string "kind", null: false
    t.boolean "system", default: false, null: false
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_roles_on_platform_admin_kind", unique: true, where: "((kind)::text = 'platform_admin'::text)"
    t.index ["organization_id", "key"], name: "index_roles_on_organization_id_and_key", unique: true
    t.index ["organization_id"], name: "index_roles_on_organization_id"
    t.check_constraint "(kind::text = ANY (ARRAY['platform_admin'::character varying, 'organization_owner'::character varying]::text[])) AND system OR kind::text = 'custom'::text AND NOT system", name: "roles_system_matches_kind"
    t.check_constraint "kind::text = 'platform_admin'::text AND organization_id IS NULL OR kind::text <> 'platform_admin'::text AND organization_id IS NOT NULL", name: "roles_organization_required_unless_platform_admin"
    t.check_constraint "kind::text = ANY (ARRAY['platform_admin'::character varying, 'organization_owner'::character varying, 'custom'::character varying]::text[])", name: "roles_kind_values"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.bigint "parent_id"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["organization_id", "parent_id"], name: "index_users_on_organization_id_and_parent_id", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["parent_id"], name: "index_users_on_parent_id"
  end

  add_foreign_key "department_assignments", "departments"
  add_foreign_key "department_assignments", "users"
  add_foreign_key "department_assignments", "users", column: "assigned_by_id"
  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "departments", "organizations"
  add_foreign_key "invitations", "roles"
  add_foreign_key "invitations", "users"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "role_assignments", "roles"
  add_foreign_key "role_assignments", "users"
  add_foreign_key "role_assignments", "users", column: "assigned_by_id"
  add_foreign_key "roles", "organizations"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "parent_id"
end
