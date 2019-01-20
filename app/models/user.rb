class User < ApplicationRecord
  # password_digest
  has_secure_password

  # model association
  has_many :carts, dependent: :destroy

  # validations
  validates_presence_of :name
  validates :balance, presence: true, numericality: { greater_than: 0 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP } 
  validates :password_confirmation, presence: true, :if => :password
  validates :password, confirmation: true, :length => { :within => 6..40 }, :if => :password
end
