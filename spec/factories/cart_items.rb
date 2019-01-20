FactoryBot.define do
  factory :cart_item do
    product_id { Faker::Number.between(1, 10) }
    price { Faker::Number.decimal(3, 2) }
    quantity { Faker::Number.number(1) }
  end
end