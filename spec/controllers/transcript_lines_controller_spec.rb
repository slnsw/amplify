# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptLinesController, type: :controller do
  describe '#resolve' do
    let!(:line) { create(:transcript_line) }

    context 'when logged in user is staff' do
      let(:user) { create(:user, :admin) }

      before do
        allow(controller).to receive(:logged_in_user).and_return(user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:resolve)
        allow(Flag).to receive(:resolve)
        post :resolve, params: { id: line.id }, as: :json
      end

      it 'calls resolve on the transcript line' do
        expect(line).to have_received(:resolve)
      end

      it 'calls Flag.resolve with the transcript line id' do
        expect(Flag).to have_received(:resolve).with(line.id)
      end

      it 'returns no_content' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when logged in user is not staff' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:logged_in_user).and_return(user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:resolve)
        allow(Flag).to receive(:resolve)
        post :resolve, params: { id: line.id }, as: :json
      end

      it 'does not call resolve on the transcript line' do
        expect(line).not_to have_received(:resolve)
      end

      it 'does not call Flag.resolve' do
        expect(Flag).not_to have_received(:resolve)
      end

      it 'returns no_content' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when no user is logged in' do
      before do
        allow(controller).to receive(:logged_in_user).and_return(nil)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:resolve)
        allow(Flag).to receive(:resolve)
        post :resolve, params: { id: line.id }, as: :json
      end

      it 'does not call resolve on the transcript line' do
        expect(line).not_to have_received(:resolve)
      end

      it 'does not call Flag.resolve' do
        expect(Flag).not_to have_received(:resolve)
      end

      it 'returns no_content' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the transcript line does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          post :resolve, params: { id: 999_999 }, as: :json
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when Flag.resolve raises an error' do
      let(:user) { create(:user, :admin) }

      before do
        allow(controller).to receive(:logged_in_user).and_return(user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:resolve)
        allow(Flag).to receive(:resolve).and_raise(StandardError.new('boom'))
      end

      it 'bubbles the error' do
        expect do
          post :resolve, params: { id: line.id }, as: :json
        end.to raise_error(StandardError, 'boom')
      end
    end
  end
end
