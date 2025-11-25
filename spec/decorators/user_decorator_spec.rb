# frozen_string_literal: true

RSpec.describe UserDecorator, type: :decorator do
  let(:user) { create(:user) }
  let(:decorator) { user.decorate }

  describe '#avatar_image' do
    context 'when user has an image' do
      before { allow(user).to receive(:image).and_return('https://example.com/avatar.jpg') }

      it 'returns the user image' do
        expect(decorator.avatar_image).to eq('https://example.com/avatar.jpg')
      end
    end

    context 'when user has no image' do
      before { allow(user).to receive(:image).and_return(nil) }

      it 'returns default Google avatar' do
        expect(decorator.avatar_image).to include('googleusercontent.com')
      end
    end
  end
end
