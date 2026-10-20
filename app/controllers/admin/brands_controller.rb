module Admin
  class BrandsController < BaseController
    include Paginatable

    def index
      brands, page_info = paginate(Brand.order(:name))
      render json: { data: brands.map { |brand| BrandSerializer.new(brand) } }.merge(page_info)
    end

    def create
      brand = Brand.create!(brand_params)
      render json: { data: BrandSerializer.new(brand) }, status: :created
    end

    private

    def brand_params
      params.require(:brand).permit(:name, custom_fields: %i[label value])
    end
  end
end
