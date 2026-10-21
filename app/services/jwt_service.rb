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
        exp: expires_at
      }
      value = JWT.encode(payload, secret, ALGORITHM)

      Token.new(value: value, expires_at: Time.zone.at(expires_at))
    end

    def decode(token)
      payload, _header = JWT.decode(token, secret, true, { algorithm: ALGORITHM })

      payload
    end

    private

    def secret
      Rails.application.secret_key_base
    end
  end
end
