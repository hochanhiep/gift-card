class ProductSerializer
  def initialize(product)
    @product = product
  end

  def as_json
    {
      id:            @product.id,
      brand_id:      @product.brand_id,
      brand_name:    @product.brand.name,
      name:          @product.name,
      denomination:  @product.denomination,
      pin_required:  @product.pin_required,
      state:         @product.state,
      custom_fields: @product.custom_fields,
      created_at:    @product.created_at,
      updated_at:    @product.updated_at
    }
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
