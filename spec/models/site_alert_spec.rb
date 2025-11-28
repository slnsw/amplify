# frozen_string_literal: true

RSpec.describe SiteAlert, type: :model do
  it {
    is_expected.to define_enum_for(:level)
      .with_values(status: 'status', warning: 'warning', error: 'error')
      .backed_by_column_of_type(:string)
  }
end
