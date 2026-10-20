class CreateProduct < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :brand, null: false, index: true, foreign_key: { on_delete: :restrict }
      t.citext  :name,             null: false
      t.decimal :denomination,     precision: 10, scale: 2, null: false
      t.integer :state,            null: false, default: 0
      t.jsonb   :custom_fields,    null: false, default: []
      t.timestamps
    end

    add_index :products, [ :brand_id, :name ], unique: true
    add_check_constraint :products, "denomination > 0", name: "products_denomination_positive"
    add_check_constraint :products, "state IN (0, 1)", name: "products_state_valid"
  end
end
