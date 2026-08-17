FactoryBot.define do
  factory :match do
    association :dashboard
    opponent_deck { :dragapult }
    result        { "win" }
    description   { Faker::Lorem.sentence }
    hand_quality  { rand(1..5) }
    played_at     { Faker::Time.backward(days: 30) }
    game_mode     { :in_person }

    trait :win  do result { "win" }  end
    trait :loss do result { "loss" } end
    trait :tie  do result { "tie" }  end

    trait :in_person do game_mode { :in_person } end
    trait :tcg_live  do game_mode { :tcg_live }  end

    trait :perfect_hand do hand_quality { 5 } end
    trait :bad_hand     do hand_quality { 1 } end
  end
end
