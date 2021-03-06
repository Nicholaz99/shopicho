FactoryBot.define do
  factory :product do
    title { Faker::Lorem.word }
    price { Faker::Number.decimal(4, 2) }
    inventory_count { Faker::Number.number(10) }
  end
end