module Client
  class CardsController < BaseController
    include Idempotent

    ERROR_STATUSES = {
      product_not_found: :not_found,
      product_unavailable: :unprocessable_content,
      idempotency_key_reused: :unprocessable_content,
      card_not_found: :not_found,
      already_cancelled: :conflict
    }.freeze

    before_action :require_idempotency_key, only: :create

    def create
      result = Cards::Issue.execute(
        client: current_user,
        product_id: params.require(:product_id),
        idempotency_key: idempotency_key
      )

      return render_error(ERROR_STATUSES.fetch(result.error), code: result.error) unless result.success?

      response.headers["Idempotent-Replayed"] = "true" if result.replayed

      render json: { data: CardSerializer.new(result.card) }, status: result.replayed ? :ok : :created
    end

    def cancel
      result = Cards::Cancel.execute(client: current_user, card_id: params[:id])

      return render_error(ERROR_STATUSES.fetch(result.error), code: result.error) unless result.success?

      render json: { data: CardSerializer.new(result.card) }
    end
  end
end
