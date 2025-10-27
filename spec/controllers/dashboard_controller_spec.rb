# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe '#index' do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive_messages(current_user: user)
    end

    context 'when user is authenticated' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
      end

      it 'responds with HTML content type' do
        get :index
        expect(response.content_type).to include 'text/html'
      end

      it 'uses the `application_v2` layout' do
        get :index
        expect(controller.class._layout).to eq 'application_v2'
      end

      context 'when has transcript edits' do
        let!(:transcript_edit) { create(:transcript_edit, user_id: user.id) }

        it 'assigns @transcript_edits for the current user' do
          get :index

          expect(assigns(:transcript_edits)).to include(transcript_edit)
        end
      end

      context 'when has no transcript edits' do
        it 'assigns an empty collection for @transcript_edits' do
          get :index

          expect(assigns(:transcript_edits)).to be_empty
        end
      end
    end

    context 'when `authenticate_user!` returns false' do
      before do
        allow(controller).to receive(:authenticate_user!).and_wrap_original do |_|
          controller.redirect_to(new_user_session_path)
        end
      end

      it 'redirects to the sign in page (or responds with a redirect)' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
