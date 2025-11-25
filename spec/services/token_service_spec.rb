# frozen_string_literal: true

RSpec.describe TokenService, type: :service do
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:exp_time) { 24.hours.from_now }

  describe '.encode' do
    it 'creates a JWT token with user_id' do
      token = described_class.encode(user_id)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'includes expiration time in the token' do
      token = described_class.encode(user_id, exp_time)
      decoded = JWT.decode(token, described_class::SECRET_KEY)[0]
      expect(decoded['exp']).to eq(exp_time.to_i)
    end
  end

  describe '.decode' do
    let(:token) { described_class.encode(user_id, exp_time) }

    it 'decodes a valid token' do
      result = described_class.decode(token)
      expect(result[:user_id]).to eq(user_id)
      expect(result[:exp]).to eq(exp_time.to_i)
    end

    it 'returns HashWithIndifferentAccess' do
      result = described_class.decode(token)
      expect(result).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(result['user_id']).to eq(user_id)
      expect(result[:user_id]).to eq(user_id)
    end

    context 'with expired token' do
      let(:expired_token) { described_class.encode(user_id, 1.hour.ago) }

      it 'raises an error for expired token' do
        expect { described_class.decode(expired_token) }
          .to raise_error(StandardError, /Invalid or expired token/)
      end
    end

    context 'with invalid token' do
      it 'raises JWT::DecodeError for invalid token format' do
        # Invalid token format raises JWT::DecodeError which is not caught by the service
        expect { described_class.decode('invalid.token.here') }
          .to raise_error(JWT::DecodeError)
      end
    end
  end
end
