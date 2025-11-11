# frozen_string_literal: true

RSpec.describe AppConfig, type: :model do
  describe 'singleton' do
    it 'includes ActiveRecord::Singleton' do
      expect(described_class.ancestors.map(&:to_s)).to include('ActiveRecord::Singleton')
    end

    it 'returns the same instance' do
      instance1 = described_class.instance
      instance2 = described_class.instance
      expect(instance1).to eq(instance2)
    end
  end

  describe 'image uploader' do
    it 'mounts ImageUploader for image attribute' do
      config = described_class.instance
      expect(config.image).to be_a(ImageUploader)
    end
  end
end
