# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlagsController, type: :controller do
  describe '#index' do
    let(:flags) { [build_stubbed(:flag)] }

    before do
      allow(Flag).to receive(:getByLine).with('123').and_return(flags)
    end

    context 'when requested format is json' do
      before { get :index, params: { transcript_line_id: '123' }, as: :json }

      it 'responds with json' do
        expect(response.content_type).to include 'application/json'
      end

      it 'assigns to `flags`' do
        expect(assigns(:flags)).to eq(flags)
      end
    end

    context 'when requested format is html' do
      it 'raises UnknownFormat' do
        expect { get :index, params: { transcript_line_id: '123' } }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end

  describe '#show' do
    let!(:flag) { create(:flag) }

    context 'when requested format is json' do
      before { get :show, params: { id: flag.id }, as: :json }

      it 'responds with json' do
        expect(response.content_type).to include 'application/json'
      end

      it 'assigns to `flag`' do
        expect(assigns(:flag)).to eq(flag)
      end
    end

    context 'when requested format is html' do
      it 'raises UnknownFormat' do
        expect { get :show, params: { id: flag.id } }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end

  describe '#create' do
    let!(:transcript_line) { create(:transcript_line, flag_count: 0) }
    let(:flag_params) { { transcript_line_id: transcript_line.id, flag_type_id: 1, text: 'reason' } }

    context 'when creating a new flag' do
      context 'when user is signed in' do
        let(:user) { create(:user) }

        before do
          allow(controller).to receive(:current_user).and_return(user)
          allow(Flag).to receive(:find_by).and_return(nil)
        end

        it 'increments the flag count on the transcript line' do
          expect { post :create, params: { flag: flag_params }, as: :json }.to change {
            transcript_line.reload.flag_count
          }.by(1)
        end

        it 'returns created status' do
          post :create, params: { flag: flag_params }, as: :json
          expect(response).to have_http_status(:created)
        end
      end

      context 'when user is anonymous' do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
          allow(Flag).to receive(:find_by).and_return(nil)
        end

        it 'increments the flag count on the transcript line' do
          expect { post :create, params: { flag: flag_params }, as: :json }.to change {
            transcript_line.reload.flag_count
          }.by(1)
        end
      end
    end

    context 'when flag already exists' do
      let(:existing_flag) { create(:flag, transcript_line: transcript_line) }

      before do
        allow(Flag).to receive(:find_by).and_return(existing_flag)
        allow(existing_flag).to receive(:update).and_return(true)
      end

      it 'returns no content' do
        patch :create, params: { flag: flag_params }, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when requested format is html' do
      it 'raises UnknownFormat' do
        allow(controller).to receive(:render).and_raise(ActionController::UnknownFormat)
        expect { post :create, params: { flag: flag_params } }.to raise_error(ActionController::UnknownFormat)
      end
    end

    context 'when saving the new flag fails' do
      before do
        failed = build(:flag, flag_params)
        allow(Flag).to receive(:new).and_return(failed)
        allow(failed).to receive_messages(save: false, errors: { title: ["can't be blank"] })
      end

      it 'returns unprocessable_entity' do
        post :create, params: { flag: flag_params }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the errors in the json response body' do
        post :create, params: { flag: flag_params }, as: :json
        expect(response.parsed_body).to include('title' => ["can't be blank"])
      end
    end
  end
end
