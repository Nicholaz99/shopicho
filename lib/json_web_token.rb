class JsonWebToken
  class << self
    HMAC_KEY = ENV['SECRET_KEY_BASE'] ? ENV['SECRET_KEY_BASE'] : Rails.application.credentials.secret_key_base
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, HMAC_KEY)
    end
 
    def decode(token)
      body = JWT.decode(token, HMAC_KEY)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
 end