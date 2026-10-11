class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :host, null: false, index: { unique: true }
      t.string :status, null: false

      t.timestamps
    end
  end
end
