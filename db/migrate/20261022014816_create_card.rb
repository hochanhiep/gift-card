class CreateCard < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.references :client,  null: false, index: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :product, null: false, index: false, foreign_key: { on_delete: :restrict }
      t.string   :idempotency_key,   null: false
      t.string   :activation_number, null: false
      t.text     :pin,               null: false
      t.decimal  :denomination,      precision: 10, scale: 2, null: false
      t.decimal  :payout_rate,       precision: 5, scale: 2, null: false
      t.integer  :state,             null: false, default: 0
      t.datetime :cancelled_at
      t.timestamps
    end

    add_index :cards, [ :client_id, :idempotency_key ], unique: true
    add_index :cards, :activation_number, unique: true
    add_index :cards, [ :client_id, :created_at ]
    add_index :cards, [ :product_id, :created_at ]
    add_index :cards, :created_at

    add_check_constraint :cards, "state IN (0, 1)", name: "cards_state_valid"
    add_check_constraint :cards, "denomination > 0", name: "cards_denomination_positive"
    add_check_constraint :cards, "payout_rate BETWEEN 0 AND 100", name: "cards_payout_rate_range"
    add_check_constraint :cards, "(state = 1) = (cancelled_at IS NOT NULL)", name: "cards_cancelled_at_matches_state"
  end
end
