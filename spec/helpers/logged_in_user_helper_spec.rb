# frozen_string_literal: true

RSpec.describe LoggedInUserHelper, type: :helper do
  let(:user) { create(:user) }

  describe '#share_token' do
    before do
      allow(helper).to receive(:logged_in_user).and_return(user)
    end

    it 'generates a token for logged in user' do
      token = helper.share_token
      expect(token).to be_present
    end

    it 'caches the token' do
      token1 = helper.share_token
      token2 = helper.share_token
      expect(token1).to eq(token2)
    end

    it 'encodes user id in token' do
      token = helper.share_token
      decoded = TokenService.decode(token)
      expect(decoded[:user_id]).to eq(user.id)
    end
  end

  describe '#logged_in_user' do
    context 'when share_token param is present' do
      let(:token) { TokenService.encode(user.id) }

      before do
        allow(helper).to receive(:params).and_return({ share_token: token })
      end

      it 'returns user from decoded token' do
        result = helper.logged_in_user
        expect(result).to eq(user)
      end

      it 'caches the user' do
        user1 = helper.logged_in_user
        user2 = helper.logged_in_user
        expect(user1.object_id).to eq(user2.object_id)
      end
    end

    context 'when share_token param is not present' do
      let(:warden) { double('warden', user: user) }

      before do
        allow(helper).to receive(:params).and_return({})
        allow(helper).to receive(:warden).and_return(warden)
      end

      it 'returns user from warden session' do
        result = helper.logged_in_user
        expect(result).to eq(user)
      end
    end
  end
end
