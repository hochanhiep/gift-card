FactoryBot.define do
  factory :client_product do
    association :client, factory: [ :user, :client ]
    product
  end
end
