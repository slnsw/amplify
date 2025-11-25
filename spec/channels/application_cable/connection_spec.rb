# frozen_string_literal: true

RSpec.describe ApplicationCable::Connection do
  it 'inherits from ActionCable::Connection::Base' do
    expect(described_class.superclass).to eq(ActionCable::Connection::Base)
  end
end
