class BrandSerializer
  def initialize(brand)
    @brand = brand
  end

  def as_json
    {
      id:            @brand.id,
      name:          @brand.name,
      state:         @brand.state,
      custom_fields: @brand.custom_fields,
      created_at:    @brand.created_at,
      updated_at:    @brand.updated_at
    }
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
