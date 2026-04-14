FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "trainer#{n}@pokemon.test" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
