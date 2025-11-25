# frozen_string_literal: true

RSpec.describe ApplicationCable::Channel do
  it 'inherits from ActionCable::Channel::Base' do
    expect(described_class.superclass).to eq(ActionCable::Channel::Base)
  end
end
