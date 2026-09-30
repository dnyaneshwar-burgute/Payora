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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_074400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_departments_on_organization_id"
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "host", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host"], name: "index_organizations_on_host", unique: true
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

  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "departments", "organizations"
  add_foreign_key "roles", "organizations"
end
