require 'rails_helper'

RSpec.describe Product, type: :model do
  # ensure Product model has a 1:m relationship with the CarrtItems model
  it { should have_many(:cart_items).dependent(:destroy) }

  # all columns are not nullable
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:inventory_count) }
end
