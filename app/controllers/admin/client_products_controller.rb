module Admin
  class ClientProductsController < BaseController
    before_action :require_client

    def show
      render_products
    end

    def update
      product_ids = params.permit(product_ids: []).fetch(:product_ids)
      before = @client.product_ids.sort
      @client.update!(product_ids: product_ids.map(&:to_i).uniq)

      AuditLog.record(
        action: AuditLog::CLIENT_PRODUCTS_UPDATE, record: @client,
        change_set: { product_ids: [ before, @client.product_ids.sort ] }
      )

      render_products
    rescue ActiveRecord::RecordNotFound
      render_error :unprocessable_content, code: :unknown_product
    end

    private

    def require_client
      @client = User.client.find_by(id: params[:client_id])

      render_error :not_found, code: :client_not_found unless @client
    end

    def render_products
      products = @client.products.includes(:brand).order(:name)

      render json: { data: products.map { |product| ProductSerializer.new(product) } }
    end
  end
end
