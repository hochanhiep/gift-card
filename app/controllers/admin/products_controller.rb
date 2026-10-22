module Admin
  class ProductsController < BaseController
    include Paginatable

    before_action :require_brand, only: %i[index create]
    before_action :require_product, only: %i[update state destroy]

    def index
      products, page_info = paginate(@brand.products.order(:name))

      render json: { data: products.map { |product| ProductSerializer.new(product) } }.merge(page_info)
    end

    def show
      render json: { data: ProductSerializer.new(Product.find(params[:id])) }
    end

    def create
      product = @brand.products.create!(product_params)

      render json: { data: ProductSerializer.new(product) }, status: :created
    end

    def update
      @product.update!(product_params)

      render json: { data: ProductSerializer.new(@product) }
    end

    def state
      @product.update!(state: params.require(:state))

      render json: { data: ProductSerializer.new(@product) }
    end

    def destroy
      @product.destroy!

      head :no_content
    rescue ActiveRecord::InvalidForeignKey
      render_error :conflict, code: :product_has_cards
    end

    private

    def require_brand
      @brand = Brand.find(params[:brand_id])
    end

    def require_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :denomination, :pin_required, custom_fields: %i[label value])
    end
  end
end
