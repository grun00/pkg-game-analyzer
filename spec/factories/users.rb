FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "trainer#{n}@pokemon.test" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :content_creator do
      role { :content_creator }
    end
  end
end
