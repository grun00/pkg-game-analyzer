FactoryBot.define do
  factory :dashboard do
    association :user
    sequence(:name) { |n| "Dashboard #{n}" }
    game_type { :pokemon }

    trait :riftbound do game_type { :riftbound } end
    trait :magic do game_type { :magic } end
  end
end
