class JwtService
  ALGORITHM = "HS256".freeze
  TTL       = 1.hour

  Token = Struct.new(:value, :expires_at, keyword_init: true)

  class << self
    def issue(user)
      issued_at = Time.now.to_i
      expires_at = issued_at + TTL.to_i

      payload = {
        sub: user.id,
        role: user.role,
        iat: issued_at,
        exp: expires_at,
        jti: SecureRandom.uuid
      }
      value = JWT.encode(payload, secret, ALGORITHM)

      Token.new(value: value, expires_at: Time.zone.at(expires_at))
    end

    def decode(token)
      payload, _header = JWT.decode(token, secret, true, { algorithm: ALGORITHM, verify_jti: method(:active_jti?) })

      payload
    end

    def revoke(payload)
      Rails.cache.write(revoked_key(payload["jti"]), true, expires_in: payload["exp"] - Time.now.to_i)
    end

    private

    def active_jti?(jti)
      jti.present? && !Rails.cache.exist?(revoked_key(jti))
    end

    def revoked_key(jti)
      "revoked_token:#{jti}"
    end

    def secret
      Rails.application.secret_key_base
    end
  end
end
