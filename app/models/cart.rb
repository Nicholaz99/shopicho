class Cart < ApplicationRecord
  # model association
  has_many :cart_items, dependent: :destroy
  belongs_to :user

  # validations
  validates_presence_of :checkout
end
