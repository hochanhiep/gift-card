class ChangeCardsPinNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :cards, :pin, true
  end
end
