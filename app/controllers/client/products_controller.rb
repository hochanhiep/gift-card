module Client
  class ProductsController < BaseController
    include Paginatable

    def index
      products, page_info = paginate(Catalog::Search.execute(current_user, params))

      render json: { data: products.includes(:brand).map { |product| ProductSerializer.new(product) } }.merge(page_info)
    end

    def show
      product = current_user.products.available.find(params[:id])

      render json: { data: ProductSerializer.new(product) }
    end
  end
end
