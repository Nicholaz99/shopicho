require 'rails_helper'

RSpec.describe Cart, type: :model do
  # ensure an item record belongs to a single todo record
  it { should belong_to(:user) }
  # ensure User model has a 1:m relationship with the Cart model
  it { should have_many(:cart_items).dependent(:destroy) }

  # ensure checkout column is updated
  it { should validate_presence_of(:checkout) }
end
