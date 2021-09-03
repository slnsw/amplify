RSpec.describe StatsService, type: :service do
  describe ".transcript_edits as admin" do
    let(:user) { create :user, :admin }
    let(:institution1) { create :institution }
    let(:institution2) { create :institution }
    let!(:collection1) { create :collection, institution: institution1 }
    let!(:collection2) { create :collection, institution: institution2 }
    let!(:transcript1) { create :transcript, collection: collection1 }
    let!(:transcript2) { create :transcript, collection: collection2 }

    before do
      create :transcript_edit, transcript: transcript1
      create :transcript_edit, transcript: transcript2
    end

    context "when not passing an institution" do
      it "shows stats for all" do
        expect(described_class.new(user).transcript_edits).
          to eq(all: 2, past_30_days: 2, past_7_days: 2, past_24_hours: 2)
      end
    end

    context "when passing institution" do
      it "shows stats for the given institution" do
        expect(described_class.new(user).transcript_edits(institution1.id)).
          to eq(all: 1, past_30_days: 1, past_7_days: 1, past_24_hours: 1)
      end
    end
  end

  describe ".completion_stats" do
    let(:user) { create :user }
    let(:institution) { create :institution }
    let!(:collection1) { create :collection, institution: institution }
    let!(:collection2) { create :collection, institution: institution }

    before do
      create :transcript, collection: collection1, percent_completed: 100, lines: 10, lines_completed: 10
      create :transcript, collection: collection2, percent_completed: 100, lines: 10, lines_completed: 10
      create :transcript, collection: collection1, percent_reviewing: 50, lines: 10, lines_completed: 5, lines_reviewing: 5
      create :transcript, collection: collection2, percent_edited: 50, lines: 10, lines_completed: 5, lines_edited: 5
      create :transcript, collection: collection1, lines: 5, lines_completed: 0, lines_reviewing: 0
    end

    context "when viewing all" do
      it "shows stats for all" do
        expect(described_class.new(user).completion_stats).
          to eq(completed: 66.67, in_draft: 11.11, in_review: 11.11, total: 5, duration: 0, not_yet_started: 11.11)
      end
    end

    context "when passing a collection" do
      it "shows stats for collection" do
        expect(described_class.new(user).completion_stats(institution.id,
                                                          collection1.id)).
          to eq(completed: 60.0, in_draft: 0.0, in_review: 20.0, total: 3, duration: 0, not_yet_started: 20.0)
      end
    end
  end
end
