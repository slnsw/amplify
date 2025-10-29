# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptsController, type: :controller do
  describe '#index' do
    let(:project) { { data: { some: 'settings' } } }
    let(:transcripts) { [build_stubbed(:transcript)] }

    before do
      allow(Project).to receive(:getActive).and_return(project)
      allow(Transcript).to receive(:get_for_homepage).and_return(transcripts)
      get :index, as: :json
    end

    it 'assigns @project_settings' do
      expect(assigns(:project_settings)).to eq(project[:data])
    end

    it 'assigns @transcripts' do
      expect(assigns(:transcripts)).to eq(transcripts)
    end
  end

  describe '#show' do
    let(:transcript) { build_stubbed(:transcript, id: 1, title: 'T') }

    before do
      allow(TranscriptService).to receive(:find_by_uid_for_admin).and_return(transcript)
      allow(TranscriptLineStatus).to receive(:allCached).and_return([])
      allow(TranscriptSpeaker).to receive(:getByTranscriptId).and_return([])
      allow(FlagType).to receive(:byCategory).and_return([])
      page_double = instance_double(Page, public_page: instance_double(PublicPage, decorate: nil))
      allow(Page).to receive(:find_by).and_return(page_double)
      allow(controller).to receive_messages(load_institution: nil, load_institution_footer: nil)
    end

    context 'when requested as html' do
      before { get :show, params: { id: 'the-uid' } }

      it 'sets body class' do
        expect(assigns(:body_class)).to eq('body--transcript-edit')
      end

      it 'sets page subtitle' do
        expect(assigns(:page_subtitle)).to eq(transcript.title)
      end
    end

    context 'when requested as json and user is logged in' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive_messages(logged_in_user: user)
        allow(TranscriptEdit).to receive(:getByTranscriptUser).and_return([])
        allow(Flag).to receive(:getByTranscriptUser).and_return([])
        get :show, params: { id: 'the-uid' }, as: :json
      end

      it 'assigns user edits' do
        expect(assigns(:user_edits)).to eq([])
      end

      it 'assigns user flags' do
        expect(assigns(:user_flags)).to eq([])
      end
    end

    context 'when requested as json and user is not logged in' do
      before do
        allow(controller).to receive_messages(logged_in_user: nil)
        allow(TranscriptEdit).to receive(:getByTranscriptSession).and_return([])
        allow(Flag).to receive(:getByTranscriptSession).and_return([])
        sess = { id: 'sess-1' }
        def sess.id = self.[](:id)
        allow(controller).to receive(:session).and_return(sess)
        get :show, params: { id: 'the-uid' }, as: :json
      end

      it 'assigns session edits' do
        expect(assigns(:user_edits)).to eq([])
      end

      it 'assigns session flags' do
        expect(assigns(:user_flags)).to eq([])
      end
    end
  end
end
