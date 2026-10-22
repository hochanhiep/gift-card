FactoryBot.define do
  factory :card do
    association :client, factory: [ :user, :client ]
    product
    sequence(:idempotency_key) { |n| "key-#{n}" }
    sequence(:activation_number) { |n| format("CARD-0000-0000-%04d", n) }
    pin          { "123456" }
    denomination { product.denomination }
    payout_rate  { client.payout_rate }

    trait :cancelled do
      state        { :cancelled }
      cancelled_at { Time.current }
    end
  end
end
