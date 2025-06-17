# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlagDecorator do
  let(:institution) { create :institution }
  let(:collection) { create :collection, institution: institution }
  let(:transcript) { create :transcript, collection: collection }
  let(:flag) { create :flag, transcript_id: transcript.id }

  let(:flag_decorator) { flag.decorate }

  context 'with institution' do
    it 'shows the institution' do
      expect(flag_decorator.institution).to eq(institution)
    end
  end
end
