FactoryBot.define do
  factory :product do
    brand
    sequence(:name) { |n| "Product #{n}" }
    denomination  { 100_000 }
    state         { :active }
    custom_fields { [] }

    trait :inactive do
      state { :inactive }
    end
  end
end

# == Schema Information
#
# Table name: products
#
#  id            :bigint           not null, primary key
#  custom_fields :jsonb            not null
#  denomination  :decimal(10, 2)   not null
#  name          :citext           not null
#  state         :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  brand_id      :bigint           not null
#
# Indexes
#
#  index_products_on_brand_id           (brand_id)
#  index_products_on_brand_id_and_name  (brand_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (brand_id => brands.id) ON DELETE => restrict
#
