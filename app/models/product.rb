class Product < ApplicationRecord
  # validations
  validates_presence_of :title, :price, :inventory_count
end
