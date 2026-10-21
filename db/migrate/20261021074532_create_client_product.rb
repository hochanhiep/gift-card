class CreateClientProduct < ActiveRecord::Migration[8.1]
  def change
    create_table :client_products do |t|
      t.references :client,  null: false, index: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :product, null: false, index: true, foreign_key: { on_delete: :restrict }
      t.timestamps
    end

    add_index :client_products, [ :client_id, :product_id ], unique: true
  end
end
