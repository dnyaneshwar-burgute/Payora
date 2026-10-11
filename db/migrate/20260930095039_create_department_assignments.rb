class CreateDepartmentAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :department_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.datetime :effective_from, null: false
      t.datetime :effective_to, null: true
      t.references :assigned_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
