# frozen_string_literal: true

RSpec.describe UserRole, type: :model do
  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:transcribing_role)
        .with_values(admin: 'admin', registered_user: 'registered_user')
        .backed_by_column_of_type(:string)
    end
  end
end
