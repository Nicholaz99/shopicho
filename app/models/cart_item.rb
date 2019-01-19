class CartItem < ApplicationRecord
  # model relation
  belongs_to :cart
  belongs_to :product

  # validations
  validates_presence_of :product_id, :quantity
end
