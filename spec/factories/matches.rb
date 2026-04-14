FactoryBot.define do
  factory :match do
    association :user
    opponent_deck { :gardevoir_ex }
    result        { "win" }
    description   { Faker::Lorem.sentence }
    hand_quality  { rand(1..5) }
    played_at     { Faker::Time.backward(days: 30) }

    trait :win  do result { "win" }  end
    trait :loss do result { "loss" } end

    trait :perfect_hand do hand_quality { 5 } end
    trait :bad_hand     do hand_quality { 1 } end
  end
end
