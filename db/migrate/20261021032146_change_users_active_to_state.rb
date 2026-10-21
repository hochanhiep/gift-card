class ChangeUsersActiveToState < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :state, :integer, null: false, default: 0
    execute "UPDATE users SET state = 1 WHERE active = false"
    remove_column :users, :active
    add_check_constraint :users, "state IN (0, 1)", name: "users_state_valid"
  end

  def down
    remove_check_constraint :users, name: "users_state_valid"
    add_column :users, :active, :boolean, null: false, default: true
    execute "UPDATE users SET active = false WHERE state = 1"
    remove_column :users, :state
  end
end
