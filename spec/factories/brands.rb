FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Brand #{n}" }
    state         { :active }
    custom_fields { [] }

    trait :inactive do
      state { :inactive }
    end
  end
end

# == Schema Information
#
# Table name: brands
#
#  id            :bigint           not null, primary key
#  custom_fields :jsonb            not null
#  name          :citext           not null
#  state         :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_brands_on_name  (name) UNIQUE
#
