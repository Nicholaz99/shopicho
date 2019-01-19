require 'rails_helper'

RSpec.describe CartItem, type: :model do
  # ensure an item record belongs to a single cart record
  it { should belong_to(:cart) }
  # ensure an item record belongs to a single product record
  it { should belong_to(:product) }

  # all columns are not nullable
  it { should validate_presence_of(:product_id) }
  it { should validate_presence_of(:quantity) }
end
