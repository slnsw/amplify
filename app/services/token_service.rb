# app/services/token_service.rb
class TokenService
  SECRET_KEY = Rails.application.secret_key_base

  # Method to encode a token with user information and expiration
  def self.encode(user_id, exp = 24.hours.from_now)
    payload = {
      user_id: user_id,
      exp: exp.to_i, # Set expiration as a UNIX timestamp
    }
    JWT.encode(payload, SECRET_KEY)
  end

  # Method to decode the token
  def self.decode(token)
    decoded_token = JWT.decode(token, SECRET_KEY)[0] # Decode the payload
    HashWithIndifferentAccess.new(decoded_token) # Return decoded token with indifferent access
  rescue JWT::ExpiredSignature, JWT::VerificationError => e
    # Handle expired token or verification error
    raise StandardError.new("Invalid or expired token: #{e.message}")
  end
end
