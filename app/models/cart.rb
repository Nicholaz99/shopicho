class Cart < ApplicationRecord
  # model association
  has_many :cart_items, dependent: :destroy
  belongs_to :user
end
