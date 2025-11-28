# frozen_string_literal: true

RSpec.describe Admin::InstitutionDecorator, type: :decorator do
  let(:institution) { create(:institution) }
  let(:decorator) { institution.decorate(context: { namespace: :admin }) }

  it 'delegates all methods to the institution' do
    expect(decorator.name).to eq(institution.name)
    expect(decorator.id).to eq(institution.id)
  end
end
