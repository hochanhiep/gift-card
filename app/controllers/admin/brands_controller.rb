module Admin
  class BrandsController < BaseController
    include Paginatable

    before_action :require_brand, only: %i[update state]

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
      @brand.update!(brand_params)

      render json: { data: BrandSerializer.new(@brand) }
    end

    def state
      @brand.update!(state: params.require(:state))

      render json: { data: BrandSerializer.new(@brand) }
    end

    private

    def require_brand
      @brand = Brand.find(params[:id])
    end

    def brand_params
      params.require(:brand).permit(:name, custom_fields: %i[label value])
    end
  end
end
