FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password    { "Password123" }
    role        { :client }
    payout_rate { 10 }
    active      { true }

    trait :client do
      role { :client }
    end

    trait :admin do
      role        { :admin }
      payout_rate { nil }
    end

    trait :inactive do
      active { false }
    end
  end
end
