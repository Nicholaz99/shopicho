class CreateCartItems < ActiveRecord::Migration[5.2]
  def change
    create_table :cart_items do |t|
      t.integer :quantity
      t.decimal :price
      t.references :cart, foreign_key: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
