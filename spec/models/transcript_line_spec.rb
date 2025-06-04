RSpec.describe TranscriptLine, type: :model do
  describe "#recalculate" do
    let(:admin) { create(:user, :admin) }
    let(:min_lines_for_consensus) { 2 }
    let(:institution) do
      FactoryBot.create :institution,
                        min_lines_for_consensus: min_lines_for_consensus
    end
    let(:original_text) { "original text" }
    let(:collection) { FactoryBot.create :collection, institution: institution }
    let!(:transcript) { FactoryBot.create :transcript, collection: collection }
    let(:transcript_line) do
      FactoryBot.create :transcript_line,
                        transcript: transcript,
                        original_text: original_text
    end
    let(:transcript_edit) do
      FactoryBot.create :transcript_edit,
                        transcript: transcript,
                        transcript_line: transcript_line
    end
    let(:project) { Project.getActive(collection.id) }

    let!(:statues) do
      # rubocop:disable Metrics/LineLength
      [
        { name: "initialized", progress: 0, description: "Line contains unedited computer-generated text" },
        { name: "editing", progress: 25, description: "Line has been edited by others" },
        { name: "reviewing", progress: 50, description: "Line is being reviewed" },
        { name: "completed", progress: 100, description: "Line has been completed" },
        { name: "flagged", progress: 150, description: "Line has been marked as incorrect or problematic" },
        { name: "archived", progress: 200, description: "Line has been archived" },
      ].each do |item|
        TranscriptLineStatus.create(name: item[:name], progress: item[:progress], description: item["description"])
      end
      # rubocop:enable Metrics/LineLength
    end

    # rubocop:disable RSpec/ExampleLength: Example has too many lines
    describe "when min_lines_for_consensus is saved in collection" do
      context "when verifying with 4 min_lines_for_consensus when institution is set as 2 min_lines_for_consensus" do
        let!(:min_lines_for_consensus) { 2 }
        let(:collection) { FactoryBot.create :collection, institution: institution, min_lines_for_consensus: 4 }

        it "uses collection min_lines_for_consensus" do
          create_edit_and_recalculate("first")
          create_edit_and_recalculate("first")
          create_edit_and_recalculate("first")
          expect(transcript_line.transcript_line_status.name).to eq("editing")

          create_edit_and_recalculate("second")
        end
      end
    end

    context "when with admin with admin transcribing role" do
      let!(:min_lines_for_consensus) { 2 }
      let(:admin) { create(:user, :admin_with_admin_transcribing_role) }

      it "bypass concensus, status is set to completed" do
        FactoryBot.create :transcript_edit, transcript: transcript, transcript_line: transcript_line, text: "first", user_id: admin.id
        re_calculate
        expect(transcript_line.transcript_line_status.name).to eq("completed")
      end
    end

    context "when with admin with registed user transcribing role" do
      let!(:min_lines_for_consensus) { 2 }
      let(:admin) { create(:user, :admin_with_registed_user_transcribing_role) }

      it "bypass concensus, status is set to completed" do
        FactoryBot.create :transcript_edit, transcript: transcript, transcript_line: transcript_line, text: "first", user_id: admin.id
        re_calculate
        expect(transcript_line.transcript_line_status.name).to eq("editing")
      end
    end

    context "when verifying with 2 min_lines_for_consensus" do
      let!(:min_lines_for_consensus) { 2 }
      let(:admin) { create(:user, :admin_with_admin_transcribing_role) }

      it "third selection should make the line as completed" do
        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("editing")

        create_edit_and_recalculate("second")
        expect(transcript_line.transcript_line_status.name).to eq("reviewing")

        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("completed")

        create_edit_and_recalculate("second")
        expect(transcript_line.text).to eq("second")

        FactoryBot.create :transcript_edit, transcript: transcript, transcript_line: transcript_line, text: "third", user_id: admin.id
        re_calculate
        expect(transcript_line.text).to eq("third")

        FactoryBot.create :transcript_edit, transcript: transcript, transcript_line: transcript_line, text: "first", user_id: admin.id
        re_calculate
        expect(transcript_line.text).to eq("first")

        FactoryBot.create :transcript_edit, transcript: transcript, transcript_line: transcript_line, text: "fourth", user_id: admin.id
        re_calculate
        expect(transcript_line.text).to eq("fourth")
      end
    end

    context "when verifying with 4 min_lines_for_consensus" do
      let!(:min_lines_for_consensus) { 4 }

      it "fifth selection should make the line as completed" do
        create_edit_and_recalculate("first")
        create_edit_and_recalculate("first")
        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("editing")

        create_edit_and_recalculate("second")
        expect(transcript_line.transcript_line_status.name).to eq("completed")
      end
    end

    context "when verifying with 4 min_lines_for_consensus with 2 sets of same edits" do
      let!(:min_lines_for_consensus) { 4 }

      it "fifth selection should make the line as completed" do
        create_edit_and_recalculate("first")
        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("editing")

        create_edit_and_recalculate("second")
        create_edit_and_recalculate("second")
        expect(transcript_line.transcript_line_status.name).to eq("reviewing")

        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("completed")
      end
    end

    context "when verifying with 4 min_lines_for_consensus with all differnt edits" do
      let!(:min_lines_for_consensus) { 4 }

      it "fifth selection should make the line as completed" do
        create_edit_and_recalculate("first")
        create_edit_and_recalculate("second")
        create_edit_and_recalculate("third")
        create_edit_and_recalculate("fourth")
        expect(transcript_line.transcript_line_status.name).to eq("reviewing")

        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("reviewing")

        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("completed")
      end
    end

    context "when verifying with 5 min_lines_for_consensus with 2 sets of same edits" do
      let!(:min_lines_for_consensus) { 5 }

      it "fifth selection should make the line as completed" do
        create_edit_and_recalculate("first")
        create_edit_and_recalculate("first")
        create_edit_and_recalculate("first")
        expect(transcript_line.transcript_line_status.name).to eq("editing")

        create_edit_and_recalculate("second")
        create_edit_and_recalculate("second")
        expect(transcript_line.transcript_line_status.name).to eq("completed")
      end
    end
    # rubocop:enable RSpec/ExampleLength: Example has too many lines
  end

  describe 'scopes' do
    xdescribe '#fuzzy_search' do # skipping this test for now as it is flakky
      subject(:fuzzy_search) { TranscriptLine.fuzzy_search(keyword) }

      let!(:jenna) do
        FactoryBot.create :transcript_line, original_text: "And Jenna bent."
      end
      let(:jenni) do
        FactoryBot.create :transcript_line, original_text: "who was Jennifer"
      end

      context 'when searching with jenna' do
        let(:keyword) { "Jenna" }

        it 'returns' do
          expect(fuzzy_search).to contain_exactly(jenna, jenni)
        end
      end
    end
  end

  private

  def create_edit_and_recalculate(text)
    create_edit(text)
    re_calculate
  end

  def create_edit(text)
    FactoryBot.create :transcript_edit,
                      transcript: transcript,
                      transcript_line: transcript_line,
                      text: text
  end

  def re_calculate
    transcript_line.recalculate(nil, project)
    transcript_line.reload
  end
end
