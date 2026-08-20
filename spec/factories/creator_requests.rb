FactoryBot.define do
  factory :creator_request do
    association :user
    status { :pending }
    message { "I stream Pokémon TCG matches weekly." }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
