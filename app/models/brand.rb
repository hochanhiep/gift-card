class Brand < ApplicationRecord
  NAME_MAX_LENGTH = 120

  has_many :products

  normalizes :name, with: ->(n) { n.strip }

  enum :state, { active: 0, inactive: 1 }, default: :active, validate: true

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }, uniqueness: { case_sensitive: false }
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
