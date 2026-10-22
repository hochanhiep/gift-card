class AddPinRequiredToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :pin_required, :boolean, null: false, default: true
  end
end
