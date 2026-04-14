FactoryBot.define do
  factory :dashboard do
    association :user
    sequence(:name) { |n| "Dashboard #{n}" }
  end
end
