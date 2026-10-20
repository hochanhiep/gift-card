class CreateBrand < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.citext  :name,          null: false
      t.integer :state,         null: false, default: 0
      t.jsonb   :custom_fields, null: false, default: []
      t.timestamps
    end

    add_index :brands, :name, unique: true
    add_check_constraint :brands, "state IN (0, 1)", name: "brands_state_valid"
  end
end
