# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :citext           not null
#  password_digest :string           not null
#  payout_rate     :decimal(5, 2)
#  role            :integer          default("client"), not null
#  state           :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password    { "Password123" }
    role        { :client }
    payout_rate { 10 }
    state       { :active }

    trait :client do
      role { :client }
    end

    trait :admin do
      role        { :admin }
      payout_rate { nil }
    end

    trait :inactive do
      state { :inactive }
    end
  end
end
