module Admin
  class BrandsController < BaseController
    include Paginatable

    def index
      brands, page_info = paginate(Brand.order(:name))

      render json: { data: brands.map { |brand| BrandSerializer.new(brand) } }.merge(page_info)
    end

    def show
      render json: { data: BrandSerializer.new(Brand.find(params[:id])) }
    end

    def create
      brand = Brand.create!(brand_params)

      render json: { data: BrandSerializer.new(brand) }, status: :created
    end

    def update
      brand = Brand.find(params[:id])
      brand.update!(brand_params)

      render json: { data: BrandSerializer.new(brand) }
    end

    private

    def brand_params
      params.require(:brand).permit(:name, custom_fields: %i[label value])
    end
  end
end
