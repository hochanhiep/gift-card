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
      product_id = params.require(:product_id)
      result = Cards::Issue.execute(client: current_user, product_id: product_id, idempotency_key: idempotency_key)

      AuditLog.record(
        action: result.success? ? AuditLog::CARD_ISSUE : AuditLog::CARD_ISSUE_REFUSED,
        record: result.card,
        metadata: {
          product_id: product_id, idempotency_key: idempotency_key, replayed: result.replayed,
          error: result.error
        }.compact
      )

      return render_error(ERROR_STATUSES.fetch(result.error), code: result.error) unless result.success?

      response.headers["Idempotent-Replayed"] = "true" if result.replayed

      render json: { data: CardSerializer.new(result.card) }, status: result.replayed ? :ok : :created
    end

    def cancel
      result = Cards::Cancel.execute(client: current_user, card_id: params[:id])

      AuditLog.record(
        action: result.success? ? AuditLog::CARD_CANCEL : AuditLog::CARD_CANCEL_REFUSED,
        record: result.card,
        metadata: { card_id: params[:id], error: result.error }.compact
      )

      return render_error(ERROR_STATUSES.fetch(result.error), code: result.error) unless result.success?

      render json: { data: CardSerializer.new(result.card) }
    end
  end
end
