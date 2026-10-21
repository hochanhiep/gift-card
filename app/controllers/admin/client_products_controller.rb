module Admin
  class ClientProductsController < BaseController
    before_action :require_client

    def show
      render json: { data: @client.products.order(:name).map { |product| ProductSerializer.new(product) } }
    end

    def update
      @client.update!(product_ids: params.fetch(:product_ids).uniq)

      render json: { data: @client.products.order(:name).map { |product| ProductSerializer.new(product) } }
    rescue ActiveRecord::RecordNotFound
      render_error :unprocessable_content, code: :unknown_product
    end

    private

    def require_client
      @client = User.client.find_by(id: params[:client_id])

      render_error :not_found, code: :client_not_found unless @client
    end
  end
end
