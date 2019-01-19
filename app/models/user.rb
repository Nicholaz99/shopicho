class User < ApplicationRecord
  # password_digest
  has_secure_password

  # model association
  has_many :carts, dependent: :destroy

  # validations
  validates_presence_of :name, :email, :password_digest, :balance
end
