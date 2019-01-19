class Product < ApplicationRecord
  # model relations
  has_many :cart_items, dependent: :destroy

  # validations
  validates_presence_of :title, :price, :inventory_count
end
