FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
  end

  factory :award_ceremony do
    sequence(:name) { |n| "The #{n}th Academy Awards" }
    locks_at { 1.week.from_now }

    # Ceremony with categories, each holding nominees. The first nominee in each
    # category is the winner, so Entry#score is predictable in specs.
    trait :with_categories do
      transient do
        category_count { 2 }
        nominee_count { 3 }
      end

      after(:create) do |ceremony, evaluator|
        evaluator.category_count.times do |c|
          category = create(:category, award_ceremony: ceremony, name: "Category #{c + 1}")
          evaluator.nominee_count.times do |n|
            create(:nominee, category: category, name: "Nominee #{c + 1}-#{n + 1}", winner: n.zero?)
          end
        end
      end
    end
  end

  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    award_ceremony
  end

  factory :nominee do
    sequence(:name) { |n| "Nominee #{n}" }
    winner { false }
    category
  end

  factory :pool do
    award_ceremony
  end

  factory :entry do
    pool
    user
  end

  factory :pick do
    entry
    category
    nominee
  end
end
