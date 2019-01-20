class AddTotalAmountToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :total_amount, :decimal, default: 0
  end
end
