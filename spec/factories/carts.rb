FactoryBot.define do
  factory :cart
  trait :checkout do
    checkout { true }
  end
end