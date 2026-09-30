class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number, null: true
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.references :parent, null: true, foreign_key: { to_table: :users }
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :users, :email_address, unique: true
    add_index :users, [ :organization_id, :parent_id ], unique: true
  end
end
