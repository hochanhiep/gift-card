module Idempotent
  extend ActiveSupport::Concern

  HEADER = "Idempotency-Key".freeze

  private

  def idempotency_key
    request.headers[HEADER]
  end

  def require_idempotency_key
    render_error :bad_request, code: :idempotency_key_missing if idempotency_key.blank?
  end
end
