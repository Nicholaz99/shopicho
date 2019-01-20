FactoryBot.define do
  factory :user do
    name { Faker::Name.unique.name }
    email { Faker::Internet.email }
    password { 'iwantinternship' }
    password_confirmation { 'iwantinternship' }
    balance { Faker::Number.decimal(4, 2) }
  end

  trait :admin do
    admin { true }
  end
end
