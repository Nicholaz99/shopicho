require 'rails_helper'

RSpec.describe User, type: :model do
  # ensure User model has a 1:m relationship with the Cart model
  it { should have_many(:carts).dependent(:destroy) }

  # all columns are not nullable
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password_digest) }
  it { should validate_presence_of(:balance) }
end
