class CartItem < ApplicationRecord
  # model relation
  belongs_to :cart
  belongs_to :product

  # validations
  validates_presence_of :quantity, :price
end
