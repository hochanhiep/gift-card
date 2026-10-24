class Product < ApplicationRecord
  include HasCustomFields
  include Auditable

  NAME_MAX_LENGTH = 120

  belongs_to :brand
  has_many :client_products, dependent: :delete_all
  has_many :cards

  normalizes :name, with: ->(n) { n.strip }

  enum :state, { active: 0, inactive: 1 }, default: :active, validate: true

  scope :available, -> { active.joins(:brand).merge(Brand.active) }

  validates :name, presence: true,
                   length: { maximum: NAME_MAX_LENGTH },
                   uniqueness: { scope: :brand_id, case_sensitive: false }
  validates :denomination, numericality: { greater_than: 0, less_than: 100_000_000 }
  validates :pin_required, inclusion: { in: [ true, false ] }

  def available?
    active? && brand.active?
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
#  pin_required  :boolean          default(TRUE), not null
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
