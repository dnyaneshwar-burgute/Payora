class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.references :organization, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :departments }

      t.timestamps
    end
  end
end
