FactoryBot.define do
  factory :content do
    association :creator, factory: %i[user content_creator]
    sequence(:title) { |n| "Guide #{n}" }
    body { Faker::Lorem.paragraph }
    content_type { :article }
    status { :published }
    game_type { :pokemon }
    published_at { Faker::Time.backward(days: 10) }

    trait :article do content_type { :article } end
    trait :guide do content_type { :guide } end

    trait :riftbound do game_type { :riftbound } end
    trait :magic do game_type { :magic } end

    trait :draft do
      status { :draft }
      published_at { nil }
    end
  end
end
