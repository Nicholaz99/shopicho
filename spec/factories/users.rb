FactoryBot.define do
  factory :user do
    name { Faker::Name.unique.name }
    email { Faker::Internet.email }
    password_digest { '$2a$10$KKYmy58RvGGVpSlr7n.TkOsFLwLpHFjEbRz6xu3Rjdx9El69W1hUi' }
    balance { Faker::Number.decimal(4, 2) }
  end

  trait :admin do
    admin { true }
  end
end
