class AuthController < ApplicationController
  skip_before_action :authenticate_request!, only: :login

  def login
    user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)

    if user.present? && user.active?
      AuditLog.record(action: AuditLog::LOGIN, user: user)
      token = JwtService.issue(user)

      render json: {
        data: {
          token: token.value,
          expires_at: token.expires_at.iso8601,
          user: { id: user.id, email: user.email, role: user.role }
        }
      }
    else
      AuditLog.record(
        action: AuditLog::LOGIN_FAILED, user: user,
        metadata: { email: params[:email].to_s, reason: user ? "inactive" : "invalid_credentials" }
      )

      render_error :unauthorized, code: :invalid_credentials
    end
  end

  def logout
    JwtService.revoke(JwtService.decode(bearer_token))
    AuditLog.record(action: AuditLog::LOGOUT)

    head :no_content
  end
end
