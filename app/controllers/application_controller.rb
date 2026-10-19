class ApplicationController < ActionController::API
  class Unauthorized < StandardError; end
  class Forbidden    < StandardError; end

  attr_reader :current_user

  rescue_from Unauthorized,     with: -> { render_error :unauthorized, code: :unauthorized }
  rescue_from JWT::DecodeError, with: -> { render_error :unauthorized, code: :invalid_token }
  rescue_from Forbidden,        with: -> { render_error :forbidden, code: :forbidden }

  before_action :authenticate_request!

  private

  def authenticate_request!
    token = request.authorization.to_s[/\ABearer (.+)\z/, 1]
    raise Unauthorized if token.blank?

    payload = JwtService.decode(token)
    user    = User.find_by(id: payload["sub"])

    raise Unauthorized unless user.present? && user.active?

    @current_user = user
  end

  def render_error(status, code:, message: I18n.t("errors.#{code}"))
    render json: { errors: [ { status: Rack::Utils.status_code(status).to_s, code: code.to_s, message: message } ] },
           status: status
  end
end
