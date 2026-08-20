FactoryBot.define do
  factory :rating do
    association :content
    association :user
    stars { rand(1..5) }
  end
end
