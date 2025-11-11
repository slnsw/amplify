# frozen_string_literal: true

RSpec.describe Collection, type: :model do
  let(:vendor) { Vendor.create(uid: 'voice_base', name: 'VoiceBase') }
  let(:institution) { FactoryBot.create :institution }
  let(:collection) do
    described_class.create!(
      description: "A summary of the collection's content",
      url: 'collection_catalogue_reference',
      uid: 'collection-uid',
      title: "The collection's title",
      vendor: vendor,
      institution_id: institution.id
    )
  end

  let(:factory_name) { :collection }

  it_behaves_like 'publishable'
  it_behaves_like 'uid_validatable'
  it_behaves_like 'uid_not_updatable'

  it { is_expected.to have_many(:transcripts).dependent(:destroy) }
  it { is_expected.to belong_to :vendor }
  it { is_expected.to belong_to :institution }

  describe 'validations' do
    describe 'presence validations' do
      it { is_expected.to validate_presence_of :vendor }
      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_presence_of :uid }
      it { is_expected.to validate_presence_of :title }
      it { is_expected.to validate_presence_of :institution_id }
    end

    describe 'uniqueness validations' do
      it { is_expected.to validate_uniqueness_of :uid }
      it { is_expected.to validate_uniqueness_of :title }
    end

    describe 'min_lines_for_consensus' do
      context 'when present' do
        it { is_expected.to validate_numericality_of(:min_lines_for_consensus) }
      end

      context 'when not present' do
        let(:collection_without_consensus) do
          build(:collection,
                vendor: vendor,
                institution: institution,
                min_lines_for_consensus: nil)
        end

        it 'is valid' do
          expect(collection_without_consensus).to be_valid
        end
      end

      context 'when non-numeric value is provided' do
        let(:collection_with_invalid_consensus) do
          build(:collection,
                vendor: vendor,
                institution: institution,
                min_lines_for_consensus: 'invalid')
        end

        it 'is invalid' do
          expect(collection_with_invalid_consensus).not_to be_valid
        end
      end
    end
  end

  describe 'scopes' do
    describe '.by_institution' do
      let(:first_institution) { create(:institution) }
      let(:second_institution) { create(:institution) }

      before do
        create(:collection, institution: first_institution)
        create(:collection, institution: second_institution)
      end

      it 'returns collections for the specified institution' do
        result = described_class.by_institution(first_institution.id)
        expect(result.pluck(:institution_id)).to all(eq(first_institution.id))
      end
    end

    describe '.with_published_institution' do
      let(:published_institution) { create(:institution, hidden: false) }
      let(:hidden_institution) { create(:institution, hidden: true) }

      before do
        create(:collection, institution: published_institution)
        create(:collection, institution: hidden_institution)
      end

      it 'includes collections from published institutions' do
        result = described_class.with_published_institution
        institution_ids = result.joins(:institution).pluck('institutions.id')
        expect(institution_ids).to include(published_institution.id)
      end

      it 'excludes collections from hidden institutions' do
        result = described_class.with_published_institution
        institution_ids = result.joins(:institution).pluck('institutions.id')
        expect(institution_ids).not_to include(hidden_institution.id)
      end
    end
  end

  describe 'class methods' do
    describe '.getForHomepage' do
      let(:project_uid) { ENV.fetch('PROJECT_ID', nil) }

      before do
        create(:collection, project_uid: project_uid, title: 'Project Collection')
        create(:collection, project_uid: 'other_project', title: 'Other Collection')
      end

      it 'returns collections for the current project' do
        result = described_class.getForHomepage
        expect(result).to be_an(ActiveRecord::Relation)
      end

      it 'orders collections by title' do
        result = described_class.getForHomepage
        expect(result.to_sql).to include('ORDER BY title')
      end

      it 'caches the result' do
        allow(Rails.cache).to receive(:fetch).and_call_original
        described_class.getForHomepage
        expect(Rails.cache).to have_received(:fetch)
          .with("#{project_uid}/collections", expires_in: 10.minutes)
      end
    end

    describe '.getForDownloadByVendor' do
      let(:project_uid) { ENV.fetch('PROJECT_ID', nil) }
      let(:result) { described_class.getForDownloadByVendor('test_vendor', project_uid) }
      let(:test_vendor) { create(:vendor, uid: 'test_vendor') }

      before do
        create(:collection,
               vendor: test_vendor,
               vendor_identifier: 'some_id',
               project_uid: project_uid)
        create(:collection,
               vendor: test_vendor,
               vendor_identifier: '',
               project_uid: project_uid)
        create(:collection,
               vendor_identifier: 'some_id',
               project_uid: project_uid)
      end

      it 'returns collections for the vendor with non-empty vendor_identifier' do
        expect(result.where(vendor: test_vendor, vendor_identifier: 'some_id')).to exist
      end

      it 'excludes collections with empty vendor_identifier' do
        expect(result.where(vendor_identifier: '')).not_to exist
      end

      it 'filters by project_uid' do
        other_project_collection = create(:collection,
                                          vendor: test_vendor,
                                          vendor_identifier: 'some_id',
                                          project_uid: 'other_project')
        expect(result).not_to include(other_project_collection)
      end

      context 'when vendor does not exist' do
        it 'handles missing vendor gracefully' do
          expect do
            described_class.getForDownloadByVendor('nonexistent_vendor', project_uid)
          end.to raise_error(NoMethodError)
        end
      end
    end

    describe '.getForUploadByVendor' do
      let(:project_uid) { ENV.fetch('PROJECT_ID', nil) }
      let(:result) { described_class.getForUploadByVendor('test_vendor', project_uid) }
      let(:test_vendor) { create(:vendor, uid: 'test_vendor') }

      before do
        create(:collection,
               vendor: test_vendor,
               vendor_identifier: '',
               project_uid: project_uid)
        create(:collection,
               vendor: test_vendor,
               vendor_identifier: 'some_id',
               project_uid: project_uid)
      end

      it 'returns collections for the vendor with empty vendor_identifier' do
        expect(result.where(vendor: test_vendor, vendor_identifier: '')).to exist
      end

      it 'excludes collections with non-empty vendor_identifier' do
        expect(result.where.not(vendor_identifier: '')).not_to exist
      end

      it 'filters by project_uid' do
        other_project_collection = create(:collection,
                                          vendor: test_vendor,
                                          vendor_identifier: '',
                                          project_uid: 'other_project')
        expect(result).not_to include(other_project_collection)
      end

      context 'when vendor does not exist' do
        it 'handles missing vendor gracefully' do
          expect do
            described_class.getForUploadByVendor('nonexistent_vendor', project_uid)
          end.to raise_error(NoMethodError)
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#to_param' do
      it "returns the collection's uid" do
        expect(collection.to_param).to eq('collection-uid')
      end
    end

    describe '#duration' do
      context 'when collection has no transcripts' do
        it 'returns 0' do
          expect(collection.duration).to eq(0)
        end
      end

      context 'when collection has transcripts with durations' do
        before do
          create(:transcript, collection: collection, duration: 100)
          create(:transcript, collection: collection, duration: 200)
        end

        it 'returns the sum of all transcript durations' do
          expect(collection.duration).to eq(300)
        end
      end

      it 'caches the result for 23 hours' do
        allow(Rails.cache).to receive(:fetch).and_call_original
        collection.duration
        expect(Rails.cache).to have_received(:fetch)
          .with("Collection:duration:#{collection.id}", expires_in: 23.hours)
      end
    end

    describe '#disk_usage' do
      context 'when collection has no transcripts' do
        it 'returns zero for image disk usage' do
          result = collection.disk_usage
          expect(result[:image]).to eq(0)
        end

        it 'returns zero for audio disk usage' do
          result = collection.disk_usage
          expect(result[:audio]).to eq(0)
        end

        it 'returns zero for script disk usage' do
          result = collection.disk_usage
          expect(result[:script]).to eq(0)
        end
      end

      context 'when collection has transcripts with disk usage' do
        let(:first_transcript) { create(:transcript, collection: collection) }
        let(:second_transcript) { create(:transcript, collection: collection) }

        before do
          allow(first_transcript).to receive(:disk_usage).and_return(
            { image: 100, audio: 200, script: 50 }
          )
          allow(second_transcript).to receive(:disk_usage).and_return(
            { image: 150, audio: 300, script: 75 }
          )
          allow(collection).to receive(:transcripts).and_return([first_transcript, second_transcript])
        end

        it 'returns aggregated image disk usage' do
          result = collection.disk_usage
          expect(result[:image]).to eq(250)
        end

        it 'returns aggregated audio disk usage' do
          result = collection.disk_usage
          expect(result[:audio]).to eq(500)
        end

        it 'returns aggregated script disk usage' do
          result = collection.disk_usage
          expect(result[:script]).to eq(125)
        end
      end

      it 'caches the result for 23 hours' do
        allow(Rails.cache).to receive(:fetch).and_call_original
        collection.disk_usage
        expect(Rails.cache).to have_received(:fetch)
          .with("Collection:disk_usage:#{collection.id}", expires_in: 23.hours)
      end
    end

    describe '#destroy' do
      let(:test_collection) { FactoryBot.create :collection }

      before do
        transcript = FactoryBot.create :transcript, collection: test_collection
        FactoryBot.create :transcript_line, transcript: transcript
        FactoryBot.create :transcript_speaker,
                          transcript: transcript,
                          collection_id: test_collection.id
      end

      it 'deletes all related transcripts' do
        expect { test_collection.destroy }
          .to change { Transcript.where(collection_id: test_collection.id).count }.from(1).to(0)
      end

      it 'deletes all related transcript lines' do
        transcript_id = test_collection.transcripts.first.id
        expect { test_collection.destroy }
          .to change { TranscriptLine.where(transcript_id: transcript_id).count }.from(1).to(0)
      end

      it 'deletes all related transcript speakers' do
        transcript_id = test_collection.transcripts.first.id
        expect { test_collection.destroy }
          .to change { TranscriptSpeaker.where(transcript_id: transcript_id).count }.from(1).to(0)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save :save_consensus_params' do
      context 'when min_lines_for_consensus is present' do
        subject(:collection_with_consensus) do
          described_class.create!(
            description: 'Test collection',
            url: 'test_url',
            uid: 'test-uid-consensus',
            title: 'Test Title',
            vendor: vendor,
            institution_id: institution.id,
            min_lines_for_consensus: 5
          )
        end

        it 'sets max_line_edits correctly' do
          expect(collection_with_consensus.max_line_edits).to eq(5)
        end

        it 'sets min_lines_for_consensus_no_edits correctly' do
          expect(collection_with_consensus.min_lines_for_consensus_no_edits).to eq(5)
        end

        it 'sets min_percent_consensus correctly' do
          expect(collection_with_consensus.min_percent_consensus).to eq(5.0 / 6.0)
        end

        it 'calculates min_percent_consensus as min_lines / (max_line_edits + 1)' do
          expect(collection_with_consensus.min_percent_consensus)
            .to eq(5.0 / (5 + 1).to_f)
        end
      end

      context 'when min_lines_for_consensus is not present' do
        subject(:collection_without_consensus) do
          described_class.create!(
            description: 'Test collection',
            url: 'test_url',
            uid: 'test-uid-no-consensus',
            title: 'Test Title No Consensus',
            vendor: vendor,
            institution_id: institution.id,
            min_lines_for_consensus: nil
          )
        end

        it 'does not set consensus-related attributes' do
          expect(collection_without_consensus.max_line_edits).to be_nil
        end
      end

      context 'when min_lines_for_consensus is updated' do
        subject(:collection_with_consensus) do
          create(:collection, min_lines_for_consensus: 3)
        end

        before do
          collection_with_consensus.update(min_lines_for_consensus: 7)
          collection_with_consensus.reload
        end

        it 'recalculates max_line_edits' do
          expect(collection_with_consensus.max_line_edits).to eq(7)
        end

        it 'recalculates min_lines_for_consensus_no_edits' do
          expect(collection_with_consensus.min_lines_for_consensus_no_edits).to eq(7)
        end

        it 'recalculates min_percent_consensus' do
          expect(collection_with_consensus.min_percent_consensus).to eq(7.0 / 8.0)
        end
      end
    end
  end

  describe 'attributes' do
    describe 'collection_url_title' do
      it 'has a default value' do
        new_collection = described_class.new
        expect(new_collection.collection_url_title).to eq(' View in Library catalogue')
      end

      it 'can be overridden' do
        new_collection = described_class.new(collection_url_title: 'Custom Title')
        expect(new_collection.collection_url_title).to eq('Custom Title')
      end
    end
  end

  describe 'tagging' do
    it 'acts as taggable on themes' do
      collection.theme_list.add('history', 'culture')
      collection.save
      expect(collection.theme_list).to include('history', 'culture')
    end
  end

  describe 'versioning' do
    it 'has paper trail enabled' do
      expect(collection).to be_versioned
    end
  end

  describe 'image uploader' do
    it 'mounts ImageUploader for image attribute' do
      expect(collection.image).to be_a(ImageUploader)
    end
  end

  describe 'transcripts ordering' do
    before do
      create(:transcript, collection: collection, title: 'Z Transcript')
      create(:transcript, collection: collection, title: 'A Transcript')
      create(:transcript, collection: collection, title: 'M Transcript')
    end

    it 'orders transcripts by title ascending' do
      expect(collection.transcripts.pluck(:title))
        .to eq(['A Transcript', 'M Transcript', 'Z Transcript'])
    end
  end
end
