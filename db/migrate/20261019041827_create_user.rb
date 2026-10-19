class CreateUser < ActiveRecord::Migration[8.1]
  def change
    enable_extension "citext"

    create_table :users do |t|
      t.citext  :email,           null: false
      t.string  :password_digest, null: false
      t.integer :role,            null: false, default: 1
      t.boolean :active,          null: false, default: true
      t.decimal :payout_rate,     precision: 5, scale: 2
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
