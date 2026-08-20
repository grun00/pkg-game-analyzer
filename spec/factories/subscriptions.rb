FactoryBot.define do
  factory :subscription do
    association :subscriber, factory: :user
    association :creator, factory: [:user, :content_creator]
  end
end
