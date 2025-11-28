# frozen_string_literal: true

RSpec.describe DeviseHelper, type: :helper do
  describe '#devise_error_messages!' do
    it 'responds to devise_error_messages!' do
      expect(helper).to respond_to(:devise_error_messages!)
    end
  end

  describe '#devise_error_messages?' do
    it 'responds to devise_error_messages?' do
      expect(helper).to respond_to(:devise_error_messages?)
    end
  end
end
