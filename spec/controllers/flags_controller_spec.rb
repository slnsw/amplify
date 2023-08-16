require 'rails_helper'

RSpec.describe FlagsController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let!(:flag) { create(:flag) }
  let(:page) { response.body }
  let(:response_json) { JSON.parse(page) }

  before { sign_in admin }

  describe '#index' do
    it 'visits index page' do
      request.accept = "application/json"
      get :index, params: { transcript_line_id: flag.transcript_line_id }

      expect(response_json['flags']).not_to be_empty
    end
  end

  describe '#show' do
    it 'visits show page' do
      request.accept = "application/json"
      get :show, params: { id: flag.id }

      expect(response_json).to eq flag.as_json.except('is_deleted', 'is_resolved')
    end
  end

  describe '#create' do
    it 'creates flag' do
      transcript_line = create(:transcript_line)
      params = {
        flag: {
          transcript_id: transcript_line.transcript_id,
          transcript_line_id: transcript_line.id,
          flag_type_id: flag.flag_type_id,
          user_id: admin.id,
          text: 'any text',
          is_resolved: 0
        }
      }

      request.accept = "application/json"
      expect { post :create, params: params }.to(
        change { Flag.count }.by(1)
      )
    end
  end
end
