# frozen_string_literal: true

RSpec.describe V2Controller, type: :controller do
  it 'inherits from ApplicationController' do
    expect(described_class.superclass).to eq(ApplicationController)
  end

  it 'uses application_v2 layout' do
    expect(described_class._layout).to eq('application_v2')
  end

  it 'defines home action' do
    expect(described_class.instance_methods(false)).to include(:home)
  end

  it 'defines edit action' do
    expect(described_class.instance_methods(false)).to include(:edit)
  end

  it 'defines search action' do
    expect(described_class.instance_methods(false)).to include(:search)
  end
end
