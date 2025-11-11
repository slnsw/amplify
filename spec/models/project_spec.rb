# frozen_string_literal: true

RSpec.describe Project do
  describe '.getActive' do
    let(:project_uid) { ENV.fetch('PROJECT_ID', 'test-project') }
    let(:project_file_path) { Rails.root.join('project', project_uid, 'project.json') }
    let(:project_data) { { 'name' => 'Test Project', 'transcriptsPerPage' => '10' } }

    before do
      allow(File).to receive(:read).with(project_file_path).and_return(project_data.to_json)
    end

    context 'without collection_id' do
      it 'returns project data with uid' do
        result = described_class.getActive
        expect(result[:uid]).to eq(project_uid)
        expect(result[:data]).to eq(project_data)
      end
    end

    context 'with collection_id' do
      let(:institution) { create(:institution) }
      let(:collection) { create(:collection, institution: institution) }

      it 'includes consensus configuration' do
        result = described_class.getActive(collection.id)
        expect(result[:data]).to have_key('consensus')
      end
    end
  end

  describe '.institution_config' do
    let(:institution) do
      create(:institution,
             max_line_edits: 5,
             min_lines_for_consensus: 3,
             min_lines_for_consensus_no_edits: 2,
             min_percent_consensus: 0.75,
             line_display_method: 'paragraphs',
             super_user_hiearchy: 10)
    end
    let(:collection) { create(:collection, institution: institution, min_lines_for_consensus: nil) }

    it 'returns institution configuration from collection or institution' do
      result = described_class.institution_config(collection.id)
      expect(result).to have_key('maxLineEdits')
      expect(result).to have_key('minLinesForConsensus')
      expect(result['lineDisplayMethod']).to eq('paragraphs')
      expect(result['superUserHiearchy']).to eq(10)
    end

    context 'when collection has min_lines_for_consensus set' do
      let(:collection) do
        create(:collection, institution: institution, min_lines_for_consensus: 7)
      end

      it 'uses collection values where available' do
        result = described_class.institution_config(collection.id)
        expect(result['maxLineEdits']).to eq(7)
        expect(result['minLinesForConsensus']).to eq(7)
      end
    end
  end
end
